from flask import Flask, render_template, request, redirect, url_for, session, flash, jsonify, send_from_directory
from flask_mysqldb import MySQL
from werkzeug.utils import secure_filename
from functools import wraps
import os
import traceback
from datetime import datetime
from config import Config

app = Flask(__name__)
app.config.from_object(Config)
app.secret_key = app.config.get('SECRET_KEY', 'your-secret-key-change-this-in-production')

mysql = MySQL(app)

ALLOWED_EXTENSIONS = app.config.get('ALLOWED_EXTENSIONS', {'pdf', 'png', 'jpg', 'jpeg'})

def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

def login_required(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if 'user_id' not in session:
            flash('Please login first.', 'error')
            return redirect(url_for('login'))
        return f(*args, **kwargs)
    return decorated_function

def role_required(*roles):
    def decorator(f):
        @wraps(f)
        def decorated_function(*args, **kwargs):
            if 'role' not in session or session['role'] not in roles:
                flash('Access denied.', 'error')
                return redirect(url_for('login'))
            return f(*args, **kwargs)
        return decorated_function
    return decorator

# ─────────────────────────────────────────
# FILE SERVING
# ─────────────────────────────────────────

@app.route('/uploads/<path:filename>')
@login_required
def serve_upload(filename):
    return send_from_directory(app.config['UPLOAD_FOLDER'], filename)

# ─────────────────────────────────────────
# AUTH
# ─────────────────────────────────────────

@app.route('/')
@app.route('/login', methods=['GET', 'POST'])
def login():
    if 'user_id' in session:
        r = session.get('role')
        if r == 'student':  return redirect(url_for('student_dashboard'))
        elif r == 'faculty': return redirect(url_for('faculty_dashboard'))
        elif r == 'admin':   return redirect(url_for('admin_dashboard'))

    if request.method == 'POST':
        email    = request.form.get('email')
        password = request.form.get('password')
        role     = request.form.get('role')

        cursor = mysql.connection.cursor()

        if role == 'admin':
            cursor.execute('SELECT * FROM admins WHERE email = %s', (email,))
            user = cursor.fetchone()
            if user and user['password'] == password:
                session['user_id'] = user['admin_id']
                session['role']    = 'admin'
                session['name']    = user['name']
                cursor.close()
                return redirect(url_for('admin_dashboard'))

        elif role == 'student':
            cursor.execute('SELECT * FROM students WHERE email = %s', (email,))
            user = cursor.fetchone()
            if user and user['password'] == password:
                session['user_id'] = user['reg_no']
                session['role']    = 'student'
                session['name']    = user['name']
                session['dept_id'] = user['dept_id']

                cursor.execute('''
                    SELECT club_id FROM membership
                    WHERE student_id = %s AND role = 'coordinator' AND status = 'approved'
                    LIMIT 1
                ''', (user['reg_no'],))
                if cursor.fetchone():
                    session['is_coordinator'] = True

                cursor.close()
                return redirect(url_for('student_dashboard'))

        elif role == 'faculty':
            try:
                cursor.execute('SELECT * FROM faculty WHERE email = %s', (email,))
                user = cursor.fetchone()

                print(f"DEBUG: email={email}, found={user is not None}")
                if user:
                    print(f"DEBUG: db_role='{user['role']}', class_incharge='{user['class_incharge']}'")

                if user and user['password'] == password:
                    session['user_id'] = user['faculty_id']
                    session['role']    = 'faculty'
                    session['name']    = user['faculty_name']

                    faculty_role            = (user['role'] or 'faculty').strip().lower()
                    session['faculty_role'] = faculty_role
                    print(f"DEBUG: faculty_role='{faculty_role}'")

                    club_roles  = {'coordinator', 'hod+coordinator', 'fa+coordinator'}
                    class_roles = {'fa', 'fa+coordinator'}

                    cursor.execute('''
                        SELECT club_id FROM clubs
                        WHERE faculty_incharge = %s AND status = 'Active' LIMIT 1
                    ''', (user['faculty_id'],))
                    club_row = cursor.fetchone()
                    session['has_club'] = (faculty_role in club_roles) and (club_row is not None)
                    print(f"DEBUG: club_row={club_row}, has_club={session['has_club']}")

                    session['has_class'] = faculty_role in class_roles
                    class_incharge = user['class_incharge']

                    if class_incharge:
                        semester  = class_incharge[:2]
                        dept_code = class_incharge[2:]
                        cursor.execute('''
                            SELECT COUNT(*) AS cnt FROM students s
                            JOIN departments d ON s.dept_id = d.dept_id
                            WHERE s.semester = %s AND d.dept_code = %s
                        ''', (semester, dept_code))
                        count = cursor.fetchone()['cnt']
                        session['class_incharge'] = class_incharge
                        print(f"DEBUG: has_class={session['has_class']}, count={count}")
                    else:
                        print(f"DEBUG: has_class={session['has_class']}, no class_incharge")

                    cursor.close()
                    print(f"DEBUG FINAL: has_club={session['has_club']}, has_class={session['has_class']}")
                    return redirect(url_for('faculty_dashboard'))

            except Exception as ex:
                print(f"DEBUG ERROR: {ex}")
                traceback.print_exc()

        cursor.close()
        flash('Invalid credentials or role.', 'error')

    return render_template('login.html')


@app.route('/logout')
def logout():
    session.clear()
    flash('You have been logged out successfully.', 'success')
    return redirect(url_for('login'))


# ─────────────────────────────────────────
# STUDENT ROUTES
# ─────────────────────────────────────────

@app.route('/student/dashboard')
@login_required
@role_required('student')
def student_dashboard():
    reg_no = session['user_id']
    cursor = mysql.connection.cursor()

    cursor.execute('''
        SELECT s.*, d.dept_name FROM students s
        LEFT JOIN departments d ON s.dept_id = d.dept_id
        WHERE s.reg_no = %s
    ''', (reg_no,))
    student = cursor.fetchone()

    cursor.execute('''
        SELECT COUNT(*) as cnt FROM membership
        WHERE student_id = %s AND status = 'approved'
    ''', (reg_no,))
    clubs_count = cursor.fetchone()['cnt']

    cursor.execute('''
        SELECT e.event_name, e.event_date, e.points, c.club_name
        FROM event_attendance ea
        JOIN events e ON ea.event_id = e.event_id
        JOIN clubs  c ON e.club_id   = c.club_id
        WHERE ea.student_id = %s
          AND e.event_date  >= CURDATE()
          AND e.status      = 'approved'
        ORDER BY e.event_date ASC
    ''', (reg_no,))
    upcoming_events = cursor.fetchall()

    cursor.execute('''
        SELECT COUNT(*) as cnt
        FROM event_attendance ea
        JOIN events e ON ea.event_id = e.event_id
        WHERE ea.student_id = %s AND e.event_date < CURDATE()
    ''', (reg_no,))
    events_attended = cursor.fetchone()['cnt']

    total_points = student['total_points'] if student else 0
    progress     = min(total_points, 100)

    cursor.execute('''
        SELECT a.*, c.club_name FROM announcements a
        LEFT JOIN clubs c ON a.club_id = c.club_id
        WHERE (a.club_id IS NULL AND (a.audience = 'all' OR a.audience = 'students' OR a.audience IS NULL))
           OR a.club_id IN (
               SELECT club_id FROM membership
               WHERE student_id = %s AND status = 'approved'
           )
        ORDER BY a.created_date DESC LIMIT 5
    ''', (reg_no,))
    announcements = cursor.fetchall()
    cursor.close()

    return render_template('student/dashboard.html',
        student=student, clubs_count=clubs_count,
        upcoming_events=upcoming_events, events_attended=events_attended,
        total_points=total_points, progress=progress, announcements=announcements)


@app.route('/student/clubs')
@login_required
@role_required('student')
def student_clubs():
    reg_no = session['user_id']
    cursor = mysql.connection.cursor()
    cursor.execute('''
        SELECT c.*, f.faculty_name, s.name AS coordinator_name,
            (SELECT COUNT(*) FROM membership WHERE club_id = c.club_id AND status = 'approved') AS member_count,
            (SELECT status  FROM membership WHERE club_id = c.club_id AND student_id = %s)      AS my_status
        FROM clubs c
        LEFT JOIN faculty    f  ON c.faculty_incharge = f.faculty_id
        LEFT JOIN membership m2 ON m2.club_id = c.club_id AND m2.role = 'coordinator' AND m2.status = 'approved'
        LEFT JOIN students   s  ON m2.student_id = s.reg_no
        WHERE c.status = 'Active'
        ORDER BY c.club_name
    ''', (reg_no,))
    clubs = cursor.fetchall()

    cursor.execute('''
        SELECT c.*, m.role, m.join_date FROM membership m
        JOIN clubs c ON m.club_id = c.club_id
        WHERE m.student_id = %s AND m.status = 'approved'
    ''', (reg_no,))
    my_clubs = cursor.fetchall()
    cursor.close()
    return render_template('student/clubs.html', clubs=clubs, my_clubs=my_clubs)


@app.route('/student/my_clubs')
@login_required
@role_required('student')
def my_clubs():
    reg_no = session['user_id']
    cursor = mysql.connection.cursor()
    cursor.execute('''
        SELECT c.*, m.role, m.join_date, f.faculty_name,
            (SELECT COUNT(*) FROM membership WHERE club_id = c.club_id AND status = 'approved') AS member_count
        FROM membership m
        JOIN clubs c ON m.club_id = c.club_id
        LEFT JOIN faculty f ON c.faculty_incharge = f.faculty_id
        WHERE m.student_id = %s AND m.status = 'approved'
        ORDER BY m.join_date DESC
    ''', (reg_no,))
    my_clubs = cursor.fetchall()
    cursor.close()
    return render_template('student/my_clubs.html', my_clubs=my_clubs)


@app.route('/student/join_club/<int:club_id>', methods=['POST'])
@login_required
@role_required('student')
def join_club(club_id):
    reg_no = session['user_id']
    cursor = mysql.connection.cursor()
    cursor.execute('SELECT * FROM membership WHERE student_id = %s AND club_id = %s', (reg_no, club_id))
    if cursor.fetchone():
        flash('You are already a member or have a pending request.', 'error')
    else:
        cursor.execute('SELECT COUNT(*) as cnt FROM membership WHERE student_id = %s AND status = "approved"', (reg_no,))
        if cursor.fetchone()['cnt'] >= 5:
            flash('Maximum 5 clubs allowed!', 'error')
        else:
            cursor.execute('''
                INSERT INTO membership (student_id, club_id, role, join_date, status)
                VALUES (%s, %s, 'member', CURDATE(), 'approved')
            ''', (reg_no, club_id))
            mysql.connection.commit()
            flash('Joined successfully!', 'success')
    cursor.close()
    return redirect(url_for('student_clubs'))


@app.route('/student/leave_club/<int:club_id>', methods=['POST'])
@login_required
@role_required('student')
def leave_club(club_id):
    cursor = mysql.connection.cursor()
    cursor.execute('DELETE FROM membership WHERE student_id = %s AND club_id = %s', (session['user_id'], club_id))
    mysql.connection.commit()
    cursor.close()
    flash('Left the club.', 'success')
    return redirect(url_for('student_clubs'))


@app.route('/student/events')
@login_required
@role_required('student')
def student_events():
    reg_no = session['user_id']
    cursor = mysql.connection.cursor()
    cursor.execute('''
        SELECT e.*, c.club_name,
            (SELECT COUNT(*) FROM event_attendance WHERE event_id = e.event_id) AS participant_count,
            (SELECT attendance_id FROM event_attendance WHERE event_id = e.event_id AND student_id = %s) AS my_participation,
            CASE WHEN e.event_date < CURDATE() THEN 'completed' ELSE e.status END AS display_status
        FROM events e
        JOIN clubs c ON e.club_id = c.club_id
        WHERE e.status = 'approved'
        ORDER BY CASE WHEN e.event_date >= CURDATE() THEN 0 ELSE 1 END, e.event_date ASC
    ''', (reg_no,))
    events = cursor.fetchall()
    cursor.close()

    for e in events:
        if e.get('event_time') is not None: e['event_time'] = str(e['event_time'])
        if e.get('event_date') is not None: e['event_date'] = str(e['event_date'])
        e['status'] = e.get('display_status', e['status'])

    return render_template('student/events.html', events=events)


@app.route('/student/my_events')
@login_required
@role_required('student')
def my_events():
    reg_no = session['user_id']
    cursor = mysql.connection.cursor()
    cursor.execute('''
        SELECT e.*, c.club_name, ea.attendance_status, ea.payment_status,
            CASE WHEN e.event_date < CURDATE() THEN 'completed' ELSE e.status END AS display_status
        FROM event_attendance ea
        JOIN events e ON ea.event_id = e.event_id
        JOIN clubs  c ON e.club_id   = c.club_id
        WHERE ea.student_id = %s
        ORDER BY e.event_date DESC
    ''', (reg_no,))
    my_events = cursor.fetchall()
    cursor.close()
    return render_template('student/my_events.html', my_events=my_events)


@app.route('/student/register_event/<int:event_id>', methods=['POST'])
@login_required
@role_required('student')
def register_event(event_id):
    reg_no = session['user_id']
    cursor = mysql.connection.cursor()

    cursor.execute('SELECT * FROM event_attendance WHERE event_id = %s AND student_id = %s', (event_id, reg_no))
    if cursor.fetchone():
        cursor.close()
        return jsonify({'success': False, 'message': 'Already registered.'})

    cursor.execute('SELECT max_participants FROM events WHERE event_id = %s', (event_id,))
    event = cursor.fetchone()
    cursor.execute('SELECT COUNT(*) as cnt FROM event_attendance WHERE event_id = %s', (event_id,))
    if cursor.fetchone()['cnt'] >= event['max_participants']:
        cursor.close()
        return jsonify({'success': False, 'message': 'Event is full!'})

    data           = request.get_json(silent=True) or {}
    payment_status = 'paid' if data.get('payment') == 'paid' else 'not_paid'

    cursor.execute('''
        INSERT INTO event_attendance (event_id, student_id, attendance_status, payment_status)
        VALUES (%s, %s, 'NA', %s)
    ''', (event_id, reg_no, payment_status))
    mysql.connection.commit()
    cursor.close()
    return jsonify({'success': True, 'payment': payment_status})


@app.route('/student/activity_points')
@login_required
@role_required('student')
def student_activity_points():
    reg_no = session['user_id']
    cursor = mysql.connection.cursor()
    cursor.execute('SELECT total_points FROM students WHERE reg_no = %s', (reg_no,))
    student      = cursor.fetchone()
    total_points = student['total_points'] if student else 0
    progress     = min(total_points, 100)

    cursor.execute('''
        SELECT ap.*, e.event_name FROM activity_points ap
        LEFT JOIN events e ON ap.event_id = e.event_id
        WHERE ap.student_id = %s ORDER BY ap.date_awarded DESC
    ''', (reg_no,))
    points_history = cursor.fetchall()

    cursor.execute('SELECT * FROM certificates WHERE student_id = %s ORDER BY upload_date DESC', (reg_no,))
    certificates = cursor.fetchall()
    cursor.close()

    return render_template('student/activity_points.html',
        total_points=total_points, progress=progress,
        points_history=points_history, certificates=certificates)


@app.route('/student/certificates')
@login_required
@role_required('student')
def my_certificates():
    reg_no        = session['user_id']
    status_filter = request.args.get('status',    'all')
    type_filter   = request.args.get('cert_type', 'all')
    cursor        = mysql.connection.cursor()

    conditions = ['cert.student_id = %s']
    params     = [reg_no]
    if status_filter != 'all':
        conditions.append('cert.status = %s')
        params.append(status_filter)
    if type_filter != 'all':
        conditions.append('cert.certificate_type = %s')
        params.append(type_filter)

    cursor.execute(f'''
        SELECT cert.*, e.event_name, c.club_name, f.faculty_name AS verified_by_name
        FROM certificates cert
        LEFT JOIN events  e ON cert.event_id    = e.event_id
        LEFT JOIN clubs   c ON e.club_id         = c.club_id
        LEFT JOIN faculty f ON cert.verified_by  = f.faculty_id
        WHERE {' AND '.join(conditions)}
        ORDER BY cert.upload_date DESC
    ''', params)
    certificates = cursor.fetchall()

    cursor.execute('''
        SELECT COUNT(*) AS total, SUM(status='pending') AS pending,
               SUM(status='approved') AS approved, SUM(status='rejected') AS rejected,
               COALESCE(SUM(points_awarded),0) AS total_points_from_certs
        FROM certificates WHERE student_id = %s
    ''', (reg_no,))
    counts = cursor.fetchone()
    cursor.close()

    return render_template('student/certificates.html',
        certificates=certificates, counts=counts,
        status_filter=status_filter, type_filter=type_filter)


@app.route('/student/certificates/<int:cert_id>')
@login_required
@role_required('student')
def certificate_detail(cert_id):
    cursor = mysql.connection.cursor()
    cursor.execute('''
        SELECT cert.*, e.event_name, c.club_name, f.faculty_name AS verified_by_name
        FROM certificates cert
        LEFT JOIN events  e ON cert.event_id   = e.event_id
        LEFT JOIN clubs   c ON e.club_id        = c.club_id
        LEFT JOIN faculty f ON cert.verified_by = f.faculty_id
        WHERE cert.certificate_id = %s AND cert.student_id = %s
    ''', (cert_id, session['user_id']))
    cert = cursor.fetchone()
    cursor.close()
    if not cert:
        flash('Certificate not found.', 'error')
        return redirect(url_for('my_certificates'))
    return render_template('student/certificate_detail.html', cert=cert)


@app.route('/student/upload_certificate', methods=['GET', 'POST'])
@login_required
@role_required('student')
def upload_certificate():
    if request.method == 'GET':
        return render_template('student/upload_certificate.html')

    if 'certificate' not in request.files:
        flash('No file selected.', 'error')
        return redirect(url_for('upload_certificate'))

    file              = request.files['certificate']
    activity_category = request.form.get('activity_type')

    if file.filename == '':
        flash('No file selected.', 'error')
        return redirect(url_for('upload_certificate'))

    if file and allowed_file(file.filename):
        filename = secure_filename(f"{session['user_id']}_{int(datetime.now().timestamp())}_{file.filename}")
        filepath = os.path.join(app.config['UPLOAD_FOLDER'], filename)
        file.save(filepath)
        cursor = mysql.connection.cursor()
        cursor.execute('''
            INSERT INTO certificates (student_id, certificate_type, file_path, status, activity_category)
            VALUES (%s, 'self_initiative', %s, 'pending', %s)
        ''', (session['user_id'], filename, activity_category))
        mysql.connection.commit()
        cursor.close()
        flash('Certificate uploaded successfully!', 'success')
    else:
        flash('Invalid file type. Allowed: pdf, png, jpg, jpeg.', 'error')

    return redirect(url_for('my_certificates'))


@app.route('/student/profile')
@login_required
@role_required('student')
def student_profile():
    cursor = mysql.connection.cursor()
    cursor.execute('''
        SELECT s.*, d.dept_name FROM students s
        LEFT JOIN departments d ON s.dept_id = d.dept_id
        WHERE s.reg_no = %s
    ''', (session['user_id'],))
    student = cursor.fetchone()
    cursor.close()
    return render_template('student/profile.html', student=student)


@app.route('/student/update_profile', methods=['POST'])
@login_required
@role_required('student')
def update_profile():
    cursor = mysql.connection.cursor()
    cursor.execute('''
        UPDATE students SET phone = %s, name = %s, email = %s, semester = %s
        WHERE reg_no = %s
    ''', (request.form.get('phone'), request.form.get('name'),
          request.form.get('email'), request.form.get('semester'), session['user_id']))
    mysql.connection.commit()
    cursor.close()
    flash('Profile updated successfully!', 'success')
    return redirect(url_for('student_profile'))


@app.route('/student/announcements')
@login_required
@role_required('student')
def student_announcements():
    cursor = mysql.connection.cursor()
    cursor.execute('''
        SELECT a.*, c.club_name FROM announcements a
        LEFT JOIN clubs c ON a.club_id = c.club_id
        WHERE (a.club_id IS NULL AND (a.audience = 'all' OR a.audience = 'students' OR a.audience IS NULL))
           OR a.club_id IN (
               SELECT club_id FROM membership WHERE student_id = %s AND status = 'approved'
           )
        ORDER BY a.created_date DESC
    ''', (session['user_id'],))
    announcements = cursor.fetchall()
    cursor.close()
    return render_template('student/announcements.html', announcements=announcements)


# ─────────────────────────────────────────
# FACULTY ROUTES
# ─────────────────────────────────────────

@app.route('/faculty/dashboard')
@login_required
@role_required('faculty')
def faculty_dashboard():
    faculty_id = session['user_id']
    cursor     = mysql.connection.cursor()

    cursor.execute('SELECT * FROM faculty WHERE faculty_id = %s', (faculty_id,))
    faculty = cursor.fetchone()

    cursor.execute('''
        SELECT c.*, (SELECT COUNT(*) FROM membership WHERE club_id = c.club_id AND status = 'approved') AS member_count
        FROM clubs c WHERE c.faculty_incharge = %s AND c.status = 'Active'
    ''', (faculty_id,))
    my_clubs = cursor.fetchall()

    cursor.execute('''
        SELECT e.*, c.club_name FROM events e
        JOIN clubs c ON e.club_id = c.club_id
        WHERE c.faculty_incharge = %s AND e.status = 'pending'
        ORDER BY e.event_date
    ''', (faculty_id,))
    pending_events = cursor.fetchall()

    cursor.execute('''
        SELECT cert.*, s.name AS student_name, s.reg_no, s.semester
        FROM certificates cert
        JOIN students s ON cert.student_id = s.reg_no
        WHERE cert.status = 'pending'
        ORDER BY cert.upload_date DESC
    ''')
    pending_certs = cursor.fetchall()

    cursor.execute('''
        SELECT a.*, c.club_name FROM announcements a
        LEFT JOIN clubs c ON a.club_id = c.club_id
        WHERE a.club_id IS NULL
          AND (a.audience = 'all' OR a.audience = 'faculty' OR a.audience IS NULL)
        ORDER BY a.created_date DESC LIMIT 10
    ''')
    announcements = cursor.fetchall()

    class_students = []
    if faculty and faculty['class_incharge']:
        semester = faculty['class_incharge'][:2]
        dept     = faculty['class_incharge'][2:]
        cursor.execute('''
            SELECT s.*, d.dept_name,
                (SELECT COUNT(*) FROM membership WHERE student_id = s.reg_no AND status = 'approved') AS clubs_joined
            FROM students s
            LEFT JOIN departments d ON s.dept_id = d.dept_id
            WHERE s.semester = %s AND s.dept_id = (
                SELECT dept_id FROM departments WHERE dept_code = %s LIMIT 1
            )
            ORDER BY s.name
        ''', (semester, dept))
        class_students = cursor.fetchall()

    cursor.close()
    return render_template('faculty/dashboard.html',
        faculty=faculty, my_clubs=my_clubs,
        pending_events=pending_events, pending_certs=pending_certs,
        announcements=announcements, class_students=class_students)


@app.route('/faculty/announcements')
@login_required
@role_required('faculty')
def faculty_announcements():
    cursor = mysql.connection.cursor()
    cursor.execute('''
        SELECT a.*, c.club_name FROM announcements a
        LEFT JOIN clubs c ON a.club_id = c.club_id
        WHERE a.club_id IS NULL
          AND (a.audience = 'all' OR a.audience = 'faculty' OR a.audience IS NULL)
        ORDER BY a.created_date DESC
    ''')
    announcements = cursor.fetchall()
    cursor.close()
    return render_template('faculty/announcement.html', announcements=announcements)


@app.route('/faculty/profile')
@login_required
@role_required('faculty')
def faculty_profile():
    cursor = mysql.connection.cursor()
    cursor.execute('SELECT * FROM faculty WHERE faculty_id = %s', (session['user_id'],))
    faculty = cursor.fetchone()
    cursor.close()
    return render_template('faculty/profile.html', faculty=faculty)


@app.route('/faculty/update_profile', methods=['POST'])
@login_required
@role_required('faculty')
def faculty_update_profile():
    cursor = mysql.connection.cursor()
    cursor.execute('UPDATE faculty SET faculty_name = %s WHERE faculty_id = %s',
                   (request.form.get('faculty_name'), session['user_id']))
    session['name'] = request.form.get('faculty_name')
    mysql.connection.commit()
    cursor.close()
    flash('Profile updated!', 'success')
    return redirect(url_for('faculty_profile'))


@app.route('/faculty/clubs')
@login_required
@role_required('faculty')
def faculty_clubs():
    faculty_id = session['user_id']
    cursor     = mysql.connection.cursor()

    cursor.execute('''
        SELECT c.*, (SELECT COUNT(*) FROM membership WHERE club_id = c.club_id AND status = 'approved') AS member_count
        FROM clubs c WHERE c.faculty_incharge = %s AND c.status = 'Active'
        ORDER BY c.club_name
    ''', (faculty_id,))
    clubs = cursor.fetchall()

    club_members = {}
    for club in clubs:
        cursor.execute('''
            SELECT m.*, s.name, s.reg_no, s.email, s.semester, s.total_points, d.dept_name
            FROM membership m
            JOIN students s ON m.student_id = s.reg_no
            LEFT JOIN departments d ON s.dept_id = d.dept_id
            WHERE m.club_id = %s AND m.status = 'approved'
            ORDER BY m.role DESC, s.name
        ''', (club['club_id'],))
        club_members[club['club_id']] = cursor.fetchall()

    cursor.close()
    return render_template('faculty/clubs.html', clubs=clubs, club_members=club_members)


@app.route('/faculty/club/remove_member/<int:club_id>/<string:student_id>', methods=['POST'])
@login_required
@role_required('faculty')
def faculty_remove_member(club_id, student_id):
    cursor = mysql.connection.cursor()
    cursor.execute("UPDATE membership SET status = 'rejected' WHERE club_id = %s AND student_id = %s", (club_id, student_id))
    mysql.connection.commit()
    cursor.close()
    return jsonify({'success': True})


@app.route('/faculty/club/restore_member/<int:club_id>/<string:student_id>', methods=['POST'])
@login_required
@role_required('faculty')
def faculty_restore_member(club_id, student_id):
    cursor = mysql.connection.cursor()
    cursor.execute("UPDATE membership SET status = 'approved' WHERE club_id = %s AND student_id = %s", (club_id, student_id))
    mysql.connection.commit()
    cursor.close()
    return jsonify({'success': True})


@app.route('/faculty/club/<int:club_id>/members')
@login_required
@role_required('faculty')
def faculty_club_members(club_id):
    cursor = mysql.connection.cursor()
    cursor.execute('''
        SELECT m.*, s.name, s.email, s.reg_no, d.dept_name, m.join_date
        FROM membership m
        JOIN students s ON m.student_id = s.reg_no
        LEFT JOIN departments d ON s.dept_id = d.dept_id
        WHERE m.club_id = %s AND m.status = 'approved'
        ORDER BY m.role DESC, s.name
    ''', (club_id,))
    members = cursor.fetchall()
    cursor.close()
    return jsonify(members)


@app.route('/faculty/events')
@login_required
@role_required('faculty')
def faculty_events():
    faculty_id    = session['user_id']
    club_filter   = request.args.get('club',   'all')
    status_filter = request.args.get('status', 'all')
    cursor        = mysql.connection.cursor()

    cursor.execute('SELECT club_id, club_name FROM clubs WHERE faculty_incharge = %s AND status = "Active"', (faculty_id,))
    my_clubs = cursor.fetchall()

    conditions = ['c.faculty_incharge = %s']
    params     = [faculty_id]
    if club_filter != 'all':
        conditions.append('e.club_id = %s')
        params.append(club_filter)
    if status_filter == 'completed':
        conditions.append('e.event_date < CURDATE()')
    elif status_filter != 'all':
        conditions.append('e.status = %s')
        params.append(status_filter)

    cursor.execute(f'''
        SELECT e.*, c.club_name,
            (SELECT COUNT(*) FROM event_attendance WHERE event_id = e.event_id) AS participant_count
        FROM events e JOIN clubs c ON e.club_id = c.club_id
        WHERE {' AND '.join(conditions)} ORDER BY e.event_date ASC
    ''', params)
    events = cursor.fetchall()
    cursor.close()

    serializable = []
    for e in events:
        row = dict(e)
        for k, v in row.items():
            if hasattr(v, 'isoformat'):
                row[k] = v.isoformat()
            elif hasattr(v, 'total_seconds'):
                t = int(v.total_seconds()); h, r = divmod(t, 3600); m, _ = divmod(r, 60)
                row[k] = f"{h:02d}:{m:02d}"
        serializable.append(row)

    return render_template('faculty/events.html',
        events=serializable, my_clubs=my_clubs,
        club_filter=club_filter, status_filter=status_filter)


@app.route('/faculty/membership_approvals')
@login_required
@role_required('faculty')
def faculty_membership_approvals():
    faculty_id    = session['user_id']
    club_filter   = request.args.get('club',   'all')
    status_filter = request.args.get('status', 'pending')
    cursor        = mysql.connection.cursor()

    cursor.execute('SELECT club_id, club_name FROM clubs WHERE faculty_incharge = %s AND status = "Active"', (faculty_id,))
    my_clubs = cursor.fetchall()

    conditions = ['c.faculty_incharge = %s']
    params     = [faculty_id]
    if club_filter != 'all':
        conditions.append('m.club_id = %s')
        params.append(club_filter)
    if status_filter != 'all':
        conditions.append('m.status = %s')
        params.append(status_filter)

    cursor.execute(f'''
        SELECT m.*, s.name AS student_name, s.reg_no, d.dept_name, c.club_name
        FROM membership m
        JOIN students s   ON m.student_id    = s.reg_no
        JOIN clubs c      ON m.club_id       = c.club_id
        JOIN faculty f    ON c.faculty_incharge = f.faculty_id
        LEFT JOIN departments d ON s.dept_id = d.dept_id
        WHERE {' AND '.join(conditions)}
        ORDER BY
          CASE m.status WHEN 'pending' THEN 0 WHEN 'approved' THEN 1 ELSE 2 END,
          m.join_date DESC
    ''', params)
    memberships = cursor.fetchall()
    cursor.close()

    return render_template('faculty/membership_approvals.html',
        memberships=memberships, my_clubs=my_clubs,
        club_filter=club_filter, status_filter=status_filter)


@app.route('/faculty/validation')
@login_required
@role_required('faculty')
def faculty_validation():
    faculty_id    = session['user_id']
    club_filter   = request.args.get('club',   'all')
    status_filter = request.args.get('status', 'pending')
    cursor        = mysql.connection.cursor()

    cursor.execute('SELECT club_id, club_name FROM clubs WHERE faculty_incharge = %s AND status = "Active"', (faculty_id,))
    my_clubs = cursor.fetchall()

    conditions = ['c.faculty_incharge = %s']
    params     = [faculty_id]
    if club_filter != 'all':
        conditions.append('e.club_id = %s')
        params.append(club_filter)
    if status_filter != 'all':
        conditions.append('e.status = %s')
        params.append(status_filter)

    cursor.execute(f'''
        SELECT e.*, c.club_name,
            (SELECT COUNT(*) FROM event_attendance WHERE event_id = e.event_id) AS participant_count
        FROM events e JOIN clubs c ON e.club_id = c.club_id
        WHERE {' AND '.join(conditions)} ORDER BY e.event_date ASC
    ''', params)
    events = cursor.fetchall()

    serializable = []
    for e in events:
        row = dict(e)
        for k, v in row.items():
            if hasattr(v, 'isoformat'):
                row[k] = v.isoformat()
            elif hasattr(v, 'total_seconds'):
                t = int(v.total_seconds()); h, r = divmod(t, 3600); m, _ = divmod(r, 60)
                row[k] = f"{h:02d}:{m:02d}"
        serializable.append(row)

    cursor.execute('''
        SELECT cert.*, s.name AS student_name, s.reg_no
        FROM certificates cert
        JOIN students s ON cert.student_id = s.reg_no
        WHERE cert.status = 'pending'
        ORDER BY cert.upload_date DESC
    ''')
    pending_certificates = cursor.fetchall()
    cursor.close()

    return render_template('faculty/validation.html',
        events=serializable, my_clubs=my_clubs,
        club_filter=club_filter, status_filter=status_filter,
        pending_certificates=pending_certificates)


@app.route('/faculty/approve_event/<int:event_id>', methods=['GET', 'POST'])
@login_required
@role_required('faculty')
def faculty_approve_event(event_id):
    cursor = mysql.connection.cursor()
    cursor.execute("UPDATE events SET status = 'approved' WHERE event_id = %s", (event_id,))
    mysql.connection.commit()
    cursor.close()
    flash('Event approved!', 'success')
    if request.method == 'POST':
        return jsonify({'success': True})
    return redirect(url_for('faculty_dashboard'))


@app.route('/faculty/reject_event/<int:event_id>', methods=['GET', 'POST'])
@login_required
@role_required('faculty')
def faculty_reject_event(event_id):
    cursor = mysql.connection.cursor()
    cursor.execute("UPDATE events SET status = 'rejected' WHERE event_id = %s", (event_id,))
    mysql.connection.commit()
    cursor.close()
    flash('Event rejected.', 'success')
    if request.method == 'POST':
        return jsonify({'success': True})
    return redirect(url_for('faculty_dashboard'))


@app.route('/faculty/verify_certificate/<int:certificate_id>', methods=['GET', 'POST'])
@login_required
@role_required('faculty')
def faculty_verify_certificate(certificate_id):
    cursor = mysql.connection.cursor()
    cursor.execute('SELECT * FROM certificates WHERE certificate_id = %s', (certificate_id,))
    cert = cursor.fetchone()

    custom_points = None
    if request.is_json:
        custom_points = request.get_json().get('points')

    points_map = {'internship': 20, 'industrial_visit': 15, 'nptel': 5, 'competition_win': 5}
    points = custom_points if custom_points else points_map.get(cert['activity_category'], 5)

    cursor.execute("UPDATE certificates SET status='approved', verified_by=%s, points_awarded=%s WHERE certificate_id=%s",
                   (session['user_id'], points, certificate_id))
    cursor.execute("INSERT INTO activity_points (student_id, event_id, certificate_id, points, description) VALUES (%s,%s,%s,%s,%s)",
                   (cert['student_id'], cert['event_id'], certificate_id, points, f"{cert['activity_category']} - Verified"))
    cursor.execute("UPDATE students SET total_points = total_points + %s WHERE reg_no = %s",
                   (points, cert['student_id']))
    mysql.connection.commit()
    cursor.close()
    flash(f'Certificate approved! {points} points awarded.', 'success')
    if request.method == 'POST':
        return jsonify({'success': True, 'points': points})
    return redirect(url_for('faculty_dashboard'))


@app.route('/faculty/reject_certificate/<int:certificate_id>', methods=['GET', 'POST'])
@login_required
@role_required('faculty')
def faculty_reject_certificate(certificate_id):
    cursor = mysql.connection.cursor()
    cursor.execute("UPDATE certificates SET status='rejected', verified_by=%s WHERE certificate_id=%s",
                   (session['user_id'], certificate_id))
    mysql.connection.commit()
    cursor.close()
    flash('Certificate rejected.', 'success')
    if request.method == 'POST':
        return jsonify({'success': True})
    return redirect(url_for('faculty_dashboard'))


@app.route('/faculty/class')
@login_required
@role_required('faculty')
def faculty_view_class():
    faculty_id = session['user_id']
    cursor     = mysql.connection.cursor()
    cursor.execute('SELECT * FROM faculty WHERE faculty_id = %s', (faculty_id,))
    faculty = cursor.fetchone()

    if not faculty:
        flash('Faculty not found.', 'error')
        return redirect(url_for('faculty_dashboard'))

    class_incharge = faculty['class_incharge']
    faculty_role   = session.get('faculty_role', '')

    if not class_incharge and faculty_role not in {'fa', 'fa+coordinator'}:
        flash('You are not assigned as a class incharge.', 'error')
        return redirect(url_for('faculty_dashboard'))

    if class_incharge:
        semester = class_incharge[:2]
        dept     = class_incharge[2:]
        cursor.execute('''
            SELECT s.*, d.dept_name,
                (SELECT COUNT(*) FROM membership WHERE student_id = s.reg_no AND status = 'approved') AS clubs_joined,
                (SELECT COUNT(*) FROM certificates WHERE student_id = s.reg_no AND status = 'pending') AS pending_certs
            FROM students s
            LEFT JOIN departments d ON s.dept_id = d.dept_id
            WHERE s.semester = %s AND s.dept_id = (
                SELECT dept_id FROM departments WHERE dept_code = %s LIMIT 1
            )
            ORDER BY s.name
        ''', (semester, dept))
        class_students = cursor.fetchall()
    else:
        class_students = []

    cursor.close()
    class_code = class_incharge or "Not Assigned"
    return render_template('faculty/class.html', faculty=faculty, class_students=class_students, class_code=class_code)


@app.route('/faculty/class/student/<string:reg_no>')
@login_required
@role_required('faculty')
def faculty_view_student(reg_no):
    faculty_id    = session['user_id']
    status_filter = request.args.get('status', 'all')
    cursor        = mysql.connection.cursor()

    cursor.execute('''
        SELECT s.*, d.dept_name FROM students s
        LEFT JOIN departments d ON s.dept_id = d.dept_id
        WHERE s.reg_no = %s
    ''', (reg_no,))
    student = cursor.fetchone()

    if not student:
        flash('Student not found.', 'error')
        return redirect(url_for('faculty_view_class'))

    conditions = ['cert.student_id = %s']
    params     = [reg_no]
    if status_filter != 'all':
        conditions.append('cert.status = %s')
        params.append(status_filter)

    cursor.execute(f'''
        SELECT cert.*, e.event_name, c.club_name, f.faculty_name AS verified_by_name
        FROM certificates cert
        LEFT JOIN events  e ON cert.event_id   = e.event_id
        LEFT JOIN clubs   c ON e.club_id        = c.club_id
        LEFT JOIN faculty f ON cert.verified_by = f.faculty_id
        WHERE {' AND '.join(conditions)}
        ORDER BY cert.upload_date DESC
    ''', params)
    certificates = cursor.fetchall()

    cursor.execute('''
        SELECT COUNT(*) AS total, SUM(status='pending') AS pending,
               SUM(status='approved') AS approved, SUM(status='rejected') AS rejected
        FROM certificates WHERE student_id = %s
    ''', (reg_no,))
    counts = cursor.fetchone()
    cursor.close()

    return render_template('faculty/student_certs.html',
        student=student, certificates=certificates,
        counts=counts, status_filter=status_filter, faculty_id=faculty_id)


@app.route('/faculty/class/certificates')
@login_required
@role_required('faculty')
def faculty_class_certificates():
    faculty_id    = session['user_id']
    status_filter = request.args.get('status', 'pending')
    cursor        = mysql.connection.cursor()

    cursor.execute('SELECT * FROM faculty WHERE faculty_id = %s', (faculty_id,))
    faculty = cursor.fetchone()

    if not faculty:
        flash('Faculty not found.', 'error')
        return redirect(url_for('faculty_dashboard'))

    class_incharge = faculty['class_incharge']
    faculty_role   = session.get('faculty_role', '')

    if not class_incharge and faculty_role not in {'fa', 'fa+coordinator'}:
        flash('You are not assigned as a class incharge.', 'error')
        return redirect(url_for('faculty_dashboard'))

    if class_incharge:
        semester = class_incharge[:2]
        dept     = class_incharge[2:]

        conditions = ['s.semester = %s', 's.dept_id = (SELECT dept_id FROM departments WHERE dept_code = %s LIMIT 1)']
        params     = [semester, dept]
        if status_filter != 'all':
            conditions.append('cert.status = %s')
            params.append(status_filter)

        cursor.execute(f'''
            SELECT cert.*, s.name AS student_name, s.reg_no, s.semester, e.event_name, c.club_name
            FROM certificates cert
            JOIN students s ON cert.student_id = s.reg_no
            LEFT JOIN events e ON cert.event_id = e.event_id
            LEFT JOIN clubs  c ON e.club_id     = c.club_id
            WHERE {' AND '.join(conditions)}
            ORDER BY cert.upload_date DESC
        ''', params)
        certificates = cursor.fetchall()
    else:
        certificates = []

    cursor.close()
    class_code = class_incharge or "Not Assigned"
    return render_template('faculty/class_certificates.html',
        certificates=certificates, status_filter=status_filter, faculty=faculty, class_code=class_code)


# ─────────────────────────────────────────
# COORDINATOR ROUTES
# ─────────────────────────────────────────

@app.route('/coordinator/dashboard')
@login_required
@role_required('student')
def coordinator_dashboard():
    if not session.get('is_coordinator'):
        flash('Access denied.', 'error')
        return redirect(url_for('student_dashboard'))

    reg_no = session['user_id']
    cursor = mysql.connection.cursor()

    cursor.execute('''
        SELECT c.*,
            (SELECT COUNT(*) FROM membership WHERE club_id = c.club_id AND status = 'approved') AS member_count,
            (SELECT COUNT(*) FROM events WHERE club_id = c.club_id AND status = 'approved' AND event_date >= CURDATE()) AS upcoming_events,
            (SELECT COUNT(*) FROM events WHERE club_id = c.club_id AND event_date < CURDATE()) AS past_events
        FROM clubs c
        JOIN membership m ON m.club_id = c.club_id
        WHERE m.student_id = %s AND m.role = 'coordinator' AND m.status = 'approved'
    ''', (reg_no,))
    coord_clubs = cursor.fetchall()

    cursor.close()
    return render_template('coordinator/dashboard.html', coord_clubs=coord_clubs)


@app.route('/coordinator/post_announcement', methods=['POST'])
@login_required
@role_required('student')
def post_announcement():
    if not session.get('is_coordinator'):
        return jsonify({'success': False}), 403

    club_id = request.form.get('club_id')
    title   = request.form.get('title')
    message = request.form.get('message')

    cursor = mysql.connection.cursor()
    cursor.execute('''
        INSERT INTO announcements (title, message, club_id, created_by)
        VALUES (%s, %s, %s, %s)
    ''', (title, message, club_id, session['user_id']))
    mysql.connection.commit()
    cursor.close()
    return jsonify({'success': True})


@app.route('/coordinator/new_event', methods=['GET', 'POST'])
@login_required
@role_required('student')
def coordinator_new_event():
    if not session.get('is_coordinator'):
        flash('Access denied.', 'error')
        return redirect(url_for('student_dashboard'))

    reg_no = session['user_id']
    cursor = mysql.connection.cursor()

    cursor.execute('''
        SELECT c.club_id, c.club_name FROM clubs c
        JOIN membership m ON m.club_id = c.club_id
        WHERE m.student_id = %s AND m.role = 'coordinator' AND m.status = 'approved'
    ''', (reg_no,))
    coord_clubs = cursor.fetchall()

    if request.method == 'POST':
        club_id = request.form.get('club_id')
        cursor.execute('''
            SELECT club_id FROM membership
            WHERE student_id = %s AND club_id = %s AND role = 'coordinator' AND status = 'approved'
        ''', (reg_no, club_id))

        if cursor.fetchone():
            cursor.execute('''
                INSERT INTO events (club_id, event_name, event_date, event_time, location,
                    description, max_participants, points, reg_fee, status, created_by)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, 'pending', %s)
            ''', (club_id, request.form['event_name'], request.form['event_date'],
                request.form['event_time'], request.form['location'],
                request.form['description'], request.form['max_participants'],
                request.form['points'], request.form.get('reg_fee_final', 0), reg_no))
            mysql.connection.commit()
            flash('Event submitted for approval!', 'success')
        else:
            flash('Invalid club selection.', 'error')

        cursor.close()
        return redirect(url_for('coordinator_dashboard'))

    cursor.close()
    return render_template('coordinator/new_event.html', coord_clubs=coord_clubs)


@app.route('/coordinator/my_events')
@login_required
@role_required('student')
def coordinator_my_events():
    if not session.get('is_coordinator'):
        flash('Access denied.', 'error')
        return redirect(url_for('student_dashboard'))

    reg_no        = session['user_id']
    selected_club = request.args.get('club', None)
    cursor        = mysql.connection.cursor()

    cursor.execute('''
        SELECT c.club_id, c.club_name FROM clubs c
        JOIN membership m ON m.club_id = c.club_id
        WHERE m.student_id = %s AND m.role = 'coordinator' AND m.status = 'approved'
    ''', (reg_no,))
    coord_clubs = cursor.fetchall()

    conditions = ['m.student_id = %s', 'm.role = "coordinator"', 'm.status = "approved"', 'e.status = "approved"']
    params     = [reg_no]
    if selected_club:
        conditions.append('c.club_id = %s')
        params.append(selected_club)

    cursor.execute(f'''
        SELECT e.*,
            c.club_name,
            (SELECT COUNT(*) FROM event_attendance WHERE event_id = e.event_id) AS participant_count,
            CASE
                WHEN e.event_date < CURDATE() THEN 'archived'
                WHEN e.event_date = CURDATE() THEN 'ongoing'
                ELSE 'upcoming'
            END AS phase
        FROM events e
        JOIN clubs c      ON e.club_id = c.club_id
        JOIN membership m ON m.club_id = c.club_id
        WHERE {' AND '.join(conditions)}
        ORDER BY FIELD(phase,'ongoing','upcoming','archived'), e.event_date ASC
    ''', params)
    events = cursor.fetchall()
    cursor.close()

    serializable = []
    for e in events:
        row = dict(e)
        for k, v in row.items():
            if hasattr(v, 'isoformat'):
                row[k] = v.isoformat()
            elif hasattr(v, 'total_seconds'):
                t = int(v.total_seconds()); h, r = divmod(t, 3600); m, _ = divmod(r, 60)
                row[k] = f"{h:02d}:{m:02d}"
        serializable.append(row)

    return render_template('coordinator/my_events.html',
        events=serializable, coord_clubs=coord_clubs, selected_club=selected_club)


@app.route('/coordinator/event_participants/<int:event_id>')
@login_required
@role_required('student')
def coordinator_event_participants(event_id):
    if not session.get('is_coordinator'):
        return jsonify([])
    cursor = mysql.connection.cursor()
    cursor.execute('''
        SELECT ea.student_id, ea.attendance_status, s.name, s.reg_no, d.dept_name
        FROM event_attendance ea
        JOIN students s    ON ea.student_id = s.reg_no
        LEFT JOIN departments d ON s.dept_id = d.dept_id
        WHERE ea.event_id = %s
        ORDER BY s.name
    ''', (event_id,))
    rows = cursor.fetchall()
    cursor.close()
    return jsonify(rows)


@app.route('/coordinator/save_attendance/<int:event_id>', methods=['POST'])
@login_required
@role_required('student')
def coordinator_save_attendance(event_id):
    if not session.get('is_coordinator'):
        return jsonify({'success': False})

    data       = request.get_json()
    attendance = data.get('attendance', {})
    cursor     = mysql.connection.cursor()

    for student_id, is_present in attendance.items():
        status = 'present' if is_present else 'absent'
        cursor.execute('''
            UPDATE event_attendance
            SET attendance_status = %s
            WHERE event_id = %s AND student_id = %s
        ''', (status, event_id, student_id))

        if is_present:
            cursor.execute('SELECT e.points FROM events e WHERE e.event_id = %s', (event_id,))
            event = cursor.fetchone()
            if event:
                cursor.execute('''
                    SELECT activity_point_id FROM activity_points
                    WHERE student_id = %s AND event_id = %s
                ''', (student_id, event_id))
                if not cursor.fetchone():
                    cursor.execute('''
                        INSERT INTO activity_points (student_id, event_id, points, description)
                        VALUES (%s, %s, %s, %s)
                    ''', (student_id, event_id, event['points'], 'Event attendance'))
                    cursor.execute('''
                        UPDATE students SET total_points = total_points + %s WHERE reg_no = %s
                    ''', (event['points'], student_id))
        else:
            cursor.execute('''
                SELECT points FROM activity_points
                WHERE student_id = %s AND event_id = %s
            ''', (student_id, event_id))
            existing = cursor.fetchone()
            if existing:
                cursor.execute('''
                    DELETE FROM activity_points WHERE student_id = %s AND event_id = %s
                ''', (student_id, event_id))
                cursor.execute('''
                    UPDATE students SET total_points = total_points - %s WHERE reg_no = %s
                ''', (existing['points'], student_id))

    mysql.connection.commit()
    cursor.close()
    return jsonify({'success': True})


@app.route('/coordinator/members')
@login_required
@role_required('student')
def coordinator_members():
    if not session.get('is_coordinator'):
        flash('Access denied.', 'error')
        return redirect(url_for('student_dashboard'))

    reg_no = session['user_id']
    cursor = mysql.connection.cursor()

    cursor.execute('''
        SELECT c.*,
            (SELECT COUNT(*) FROM membership WHERE club_id = c.club_id AND status = 'approved') AS member_count
        FROM clubs c
        JOIN membership m ON m.club_id = c.club_id
        WHERE m.student_id = %s AND m.role = 'coordinator' AND m.status = 'approved'
    ''', (reg_no,))
    coord_clubs = cursor.fetchall()

    club_members = {}
    for club in coord_clubs:
        cursor.execute('''
            SELECT m.role, s.name, s.reg_no, s.semester, s.total_points, d.dept_name
            FROM membership m
            JOIN students s     ON m.student_id = s.reg_no
            LEFT JOIN departments d ON s.dept_id = d.dept_id
            WHERE m.club_id = %s AND m.status = 'approved'
            ORDER BY m.role DESC, s.name
        ''', (club['club_id'],))
        club_members[club['club_id']] = cursor.fetchall()

    cursor.close()
    return render_template('coordinator/members.html',
        coord_clubs=coord_clubs, club_members=club_members)


@app.route('/coordinator/make_coordinator/<int:club_id>/<string:student_id>', methods=['POST'])
@login_required
@role_required('student')
def coordinator_make_coordinator(club_id, student_id):
    if not session.get('is_coordinator'):
        return jsonify({'success': False})

    reg_no = session['user_id']
    cursor = mysql.connection.cursor()

    cursor.execute('''
        SELECT membership_id FROM membership
        WHERE student_id = %s AND club_id = %s AND role = 'coordinator' AND status = 'approved'
    ''', (reg_no, club_id))
    if not cursor.fetchone():
        cursor.close()
        return jsonify({'success': False, 'message': 'Not authorized'})

    cursor.execute('''
        SELECT student_id FROM membership
        WHERE club_id = %s AND role = 'coordinator' AND status = 'approved'
    ''', (club_id,))
    old_coord = cursor.fetchone()
    old_coordinator_id = old_coord['student_id'] if old_coord else None

    cursor.execute('''
        UPDATE membership SET role = 'member'
        WHERE club_id = %s AND role = 'coordinator' AND status = 'approved'
    ''', (club_id,))

    cursor.execute('''
        UPDATE membership SET role = 'coordinator'
        WHERE club_id = %s AND student_id = %s AND status = 'approved'
    ''', (club_id, student_id))

    cursor.execute('UPDATE clubs SET coordinator_id = %s WHERE club_id = %s', (student_id, club_id))

    mysql.connection.commit()
    cursor.close()

    return jsonify({'success': True, 'old_coordinator_id': old_coordinator_id})


# ─────────────────────────────────────────
# ADMIN ROUTES
# ─────────────────────────────────────────

@app.route('/admin/dashboard')
@login_required
@role_required('admin')
def admin_dashboard():
    cursor = mysql.connection.cursor()
    cursor.execute('SELECT COUNT(*) as cnt FROM students')
    total_students = cursor.fetchone()['cnt']
    cursor.execute("SELECT COUNT(*) as cnt FROM clubs WHERE status = 'Active'")
    active_clubs = cursor.fetchone()['cnt']
    cursor.execute("SELECT COUNT(*) as cnt FROM events WHERE status = 'approved'")
    total_events = cursor.fetchone()['cnt']
    cursor.execute('SELECT COUNT(*) as cnt FROM faculty')
    total_faculty = cursor.fetchone()['cnt']
    cursor.execute("SELECT COUNT(*) as cnt FROM students WHERE total_points >= 100")
    eligible_students = cursor.fetchone()['cnt']
    cursor.execute("SELECT COUNT(*) as cnt FROM membership WHERE status = 'pending'")
    pending_memberships = cursor.fetchone()['cnt']
    cursor.execute("SELECT COUNT(*) as cnt FROM certificates WHERE status = 'pending'")
    pending_certs = cursor.fetchone()['cnt']
    cursor.execute('''
        SELECT c.club_name, COUNT(m.membership_id) AS members
        FROM clubs c
        LEFT JOIN membership m ON c.club_id = m.club_id AND m.status = 'approved'
        GROUP BY c.club_id ORDER BY members DESC LIMIT 5
    ''')
    top_clubs = cursor.fetchall()
    cursor.close()
    return render_template('admin/dashboard.html',
        total_students=total_students, active_clubs=active_clubs,
        total_events=total_events, total_faculty=total_faculty,
        eligible_students=eligible_students, pending_memberships=pending_memberships,
        pending_certs=pending_certs, top_clubs=top_clubs)


@app.route('/admin/students', methods=['GET', 'POST'])
@login_required
@role_required('admin')
def admin_students():
    cursor = mysql.connection.cursor()

    if request.method == 'POST':
        action = request.form.get('action')

        if action == 'add':
            cursor.execute('''
                INSERT INTO students (reg_no, name, email, phone, semester, dept_id, password)
                VALUES (%s, %s, %s, %s, %s, %s, %s)
            ''', (
                request.form['reg_no'], request.form['name'],
                request.form['email'],  request.form.get('phone', ''),
                request.form['semester'], request.form['dept_id'],
                request.form['password']
            ))
            mysql.connection.commit()
            flash('Student added successfully!', 'success')

        elif action == 'edit':
            cursor.execute('''
                UPDATE students SET name=%s, email=%s, phone=%s, semester=%s, dept_id=%s
                WHERE reg_no=%s
            ''', (
                request.form['name'], request.form['email'],
                request.form.get('phone', ''), request.form['semester'],
                request.form['dept_id'], request.form['reg_no']
            ))
            mysql.connection.commit()
            flash('Student updated successfully!', 'success')

        elif action == 'delete':
            reg_no = request.form['reg_no']
            cursor.execute('DELETE FROM event_attendance WHERE student_id = %s', (reg_no,))
            cursor.execute('DELETE FROM activity_points   WHERE student_id = %s', (reg_no,))
            cursor.execute('DELETE FROM certificates      WHERE student_id = %s', (reg_no,))
            cursor.execute('DELETE FROM membership        WHERE student_id = %s', (reg_no,))
            cursor.execute('DELETE FROM students          WHERE reg_no     = %s', (reg_no,))
            mysql.connection.commit()
            flash('Student deleted.', 'success')

        cursor.close()
        return redirect(url_for('admin_students'))

    cursor.execute('''
        SELECT s.*, d.dept_name FROM students s
        LEFT JOIN departments d ON s.dept_id = d.dept_id
        ORDER BY s.name
    ''')
    students = cursor.fetchall()

    cursor.execute('SELECT * FROM departments ORDER BY dept_name')
    departments = cursor.fetchall()

    cursor.close()
    return render_template('admin/student.html', students=students, departments=departments)


@app.route('/admin/faculty', methods=['GET', 'POST'])
@login_required
@role_required('admin')
def admin_faculty():
    cursor = mysql.connection.cursor()

    if request.method == 'POST':
        action = request.form.get('action')

        if action == 'add':
            cursor.execute('''
                INSERT INTO faculty (faculty_name, email, department, class_incharge, password, role)
                VALUES (%s, %s, %s, %s, %s, %s)
            ''', (
                request.form['faculty_name'], request.form['email'],
                request.form['department'],   request.form.get('class_incharge') or None,
                request.form['password'],     request.form.get('role', 'faculty')
            ))
            mysql.connection.commit()
            flash('Faculty added successfully!', 'success')

        elif action == 'edit_faculty':
            cursor.execute('''
                UPDATE faculty SET faculty_name=%s, email=%s, department=%s,
                    class_incharge=%s, role=%s
                WHERE faculty_id=%s
            ''', (
                request.form['faculty_name'], request.form['email'],
                request.form['department'],   request.form.get('class_incharge') or None,
                request.form.get('role', 'faculty'), request.form['faculty_id']
            ))
            mysql.connection.commit()
            flash('Faculty updated successfully!', 'success')

        elif action == 'delete_faculty':
            fid = request.form['faculty_id']
            cursor.execute('UPDATE clubs SET faculty_incharge = NULL WHERE faculty_incharge = %s', (fid,))
            cursor.execute('UPDATE certificates SET verified_by = NULL WHERE verified_by = %s', (fid,))
            cursor.execute('DELETE FROM faculty WHERE faculty_id = %s', (fid,))
            mysql.connection.commit()
            flash('Faculty deleted.', 'success')

        cursor.close()
        return redirect(url_for('admin_faculty'))

    cursor.execute('SELECT * FROM faculty ORDER BY faculty_name')
    faculty_list = cursor.fetchall()
    cursor.close()
    return render_template('admin/faculty.html', faculty_list=faculty_list)


@app.route('/admin/departments', methods=['GET', 'POST'])
@login_required
@role_required('admin')
def admin_departments():
    cursor = mysql.connection.cursor()

    if request.method == 'POST':
        action = request.form.get('action')
        if action == 'add':
            cursor.execute('''
                INSERT INTO departments (dept_name, dept_code, hod_name)
                VALUES (%s, %s, %s)
            ''', (request.form['dept_name'], request.form['dept_code'], request.form.get('hod_name')))
            mysql.connection.commit()
            flash('Department added!', 'success')
        cursor.close()
        return redirect(url_for('admin_departments'))

    cursor.execute('SELECT * FROM departments ORDER BY dept_name')
    departments = cursor.fetchall()
    cursor.close()
    return render_template('admin/department.html', departments=departments)


@app.route('/admin/clubs', methods=['GET', 'POST'])
@login_required
@role_required('admin')
def admin_clubs():
    cursor = mysql.connection.cursor()

    if request.method == 'POST':
        action = request.form.get('action')
        if action == 'add':
            cursor.execute('''
                INSERT INTO clubs (club_name, club_type, faculty_incharge, created_date, status)
                VALUES (%s, %s, %s, CURDATE(), 'Active')
            ''', (request.form['club_name'], request.form['club_type'], request.form['faculty_incharge']))
            mysql.connection.commit()
            flash('Club created!', 'success')
        cursor.close()
        return redirect(url_for('admin_clubs'))

    cursor.execute('''
        SELECT c.*, f.faculty_name,
            (SELECT COUNT(*) FROM membership WHERE club_id = c.club_id AND status = 'approved') AS members
        FROM clubs c
        LEFT JOIN faculty f ON c.faculty_incharge = f.faculty_id
        ORDER BY c.club_name
    ''')
    clubs = cursor.fetchall()

    cursor.execute('SELECT * FROM faculty ORDER BY faculty_name')
    faculty_list = cursor.fetchall()
    cursor.close()
    return render_template('admin/clubs.html', clubs=clubs, faculty_list=faculty_list)


@app.route('/admin/clubs/toggle/<int:club_id>')
@login_required
@role_required('admin')
def toggle_club(club_id):
    cursor = mysql.connection.cursor()
    cursor.execute("SELECT status FROM clubs WHERE club_id = %s", (club_id,))
    club = cursor.fetchone()
    new_status = 'Inactive' if club['status'] == 'Active' else 'Active'
    cursor.execute("UPDATE clubs SET status = %s WHERE club_id = %s", (new_status, club_id))
    mysql.connection.commit()
    cursor.close()
    flash(f'Club status updated to {new_status}.', 'success')
    return redirect(url_for('admin_clubs'))


@app.route('/admin/memberships')
@login_required
@role_required('admin')
def admin_memberships():
    cursor = mysql.connection.cursor()
    cursor.execute('''
        SELECT m.*, s.name AS student_name, s.reg_no, c.club_name
        FROM membership m
        JOIN students s ON m.student_id = s.reg_no
        JOIN clubs c    ON m.club_id    = c.club_id
        ORDER BY m.join_date DESC
    ''')
    memberships = cursor.fetchall()
    cursor.close()
    return render_template('admin/memberships.html', memberships=memberships)


@app.route('/admin/events')
@login_required
@role_required('admin')
def admin_events():
    cursor = mysql.connection.cursor()
    cursor.execute('''
        SELECT e.*, c.club_name, f.faculty_name
        FROM events e
        JOIN clubs c   ON e.club_id          = c.club_id
        LEFT JOIN faculty f ON c.faculty_incharge = f.faculty_id
        ORDER BY e.event_date DESC
    ''')
    events = cursor.fetchall()
    cursor.close()
    return render_template('admin/events.html', events=events)


@app.route('/admin/reports')
@login_required
@role_required('admin')
def admin_reports():
    cursor = mysql.connection.cursor()
    cursor.execute('''
        SELECT s.reg_no, s.name, d.dept_name, s.semester, s.total_points,
            CASE WHEN s.total_points >= 100 THEN 'Eligible' ELSE 'Not Eligible' END AS grad_status
        FROM students s
        LEFT JOIN departments d ON s.dept_id = d.dept_id
        ORDER BY s.total_points DESC
    ''')
    report = cursor.fetchall()

    cursor.execute("SELECT COUNT(*) as cnt FROM students WHERE total_points >= 100")
    eligible = cursor.fetchone()['cnt']

    cursor.execute("SELECT COUNT(*) as cnt FROM students")
    total = cursor.fetchone()['cnt']

    cursor.execute('''
        SELECT d.dept_name, COALESCE(AVG(s.total_points), 0) AS avg_pts
        FROM departments d
        LEFT JOIN students s ON s.dept_id = d.dept_id
        GROUP BY d.dept_id ORDER BY avg_pts DESC
    ''')
    dept_stats = cursor.fetchall()
    cursor.close()
    return render_template('admin/reports.html', report=report, eligible=eligible, total=total, dept_stats=dept_stats)


@app.route('/admin/announcements', methods=['GET', 'POST'])
@login_required
@role_required('admin')
def admin_announcements():
    cursor = mysql.connection.cursor()

    if request.method == 'POST':
        action = request.form.get('action')

        if action == 'add':
            cursor.execute('''
                INSERT INTO announcements (title, message, created_by, audience)
                VALUES (%s, %s, %s, %s)
            ''', (
                request.form['title'],
                request.form['message'],
                session['name'],
                request.form.get('audience', 'all')
            ))
            mysql.connection.commit()
            flash('Announcement posted!', 'success')

        elif action == 'delete':
            cursor.execute('DELETE FROM announcements WHERE announcement_id = %s',
                           (request.form['announcement_id'],))
            mysql.connection.commit()
            flash('Announcement deleted.', 'success')

        cursor.close()
        return redirect(url_for('admin_announcements'))

    cursor.execute('''
        SELECT * FROM announcements
        WHERE club_id IS NULL
        ORDER BY created_date DESC
    ''')
    announcements = cursor.fetchall()
    cursor.close()
    return render_template('admin/announcement.html', announcements=announcements)


# ─────────────────────────────────────────
# API ENDPOINTS
# ─────────────────────────────────────────

@app.route('/api/top_student')
@login_required
def api_top_student():
    cursor = mysql.connection.cursor()
    cursor.execute('SELECT name, total_points FROM students ORDER BY total_points DESC LIMIT 1')
    top_student = cursor.fetchone()
    cursor.close()
    return jsonify(top_student)


@app.route('/api/top_organizer')
@login_required
def api_top_organizer():
    cursor = mysql.connection.cursor()
    cursor.execute('''
        SELECT s.name, COUNT(e.event_id) AS event_count
        FROM students s
        JOIN membership m ON s.reg_no  = m.student_id
        JOIN clubs      c ON m.club_id = c.club_id
        JOIN events     e ON c.club_id = e.club_id
        WHERE m.role = 'coordinator' AND m.status = 'approved'
        GROUP BY s.reg_no, s.name
        ORDER BY event_count DESC LIMIT 1
    ''')
    top_organizer = cursor.fetchone()
    cursor.close()
    return jsonify(top_organizer)


if __name__ == '__main__':
    os.makedirs(app.config['UPLOAD_FOLDER'], exist_ok=True)
    app.run(debug=True, host='0.0.0.0', port=5000)