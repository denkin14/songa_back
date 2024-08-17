#!/usr/bin/python3
import MySQLdb
import secrets
from flask_bcrypt import Bcrypt
from flask import Flask, render_template, url_for, redirect, flash, session, request
from apscheduler.schedulers.background import BackgroundScheduler

# Database connection
conn = MySQLdb.connect(host="localhost", user="root", passwd="Musicgood#1_", db="nobuk_db")

app = Flask(__name__)
bcrypt = Bcrypt(app)

app.config['SECRET_KEY'] = '414d09b5b79cd5230f799c811d2f28b6'

@app.route("/home")
def nobuk_home():
    return render_template("home.html", user=session.get('client_id'))

@app.route("/group/create", methods=['GET', 'POST'])
def create_group():
    if request.method == 'POST':
        name = request.form['name']
        description = request.form['description']
        cur = conn.cursor()
        cur.execute("INSERT INTO groups (name, description, admin_id) VALUES (%s, %s, %s)",
                    (name, description, session.get('client_id')))
        conn.commit()
        cur.close()
        flash('Group created successfully!', 'success')
        return redirect(url_for('group_list'))
    return render_template("create_group.html")

@app.route("/groups")
def group_list():
    cur = conn.cursor()
    cur.execute("SELECT * FROM groups WHERE admin_id = %s", (session.get('client_id'),))
    groups = cur.fetchall()
    cur.close()
    return render_template("group_list.html", groups=groups)

@app.route("/payment/create", methods=['GET', 'POST'])
def create_payment():
    if request.method == 'POST':
        group_id = request.form['group_id']
        amount = request.form['amount']
        cur = conn.cursor()
        cur.execute("INSERT INTO payments (group_id, member_id, amount, status) VALUES (%s, %s, %s, 'PENDING')",
                    (group_id, session.get('client_id'), amount))
        conn.commit()
        cur.close()
        flash('Payment link created successfully!', 'success')
        return redirect(url_for('payment_list'))
    cur = conn.cursor()
    cur.execute("SELECT id, name FROM groups WHERE admin_id = %s", (session.get('client_id'),))
    groups = cur.fetchall()
    cur.close()
    return render_template("create_payment.html", groups=groups)

@app.route("/payments")
def payment_list():
    cur = conn.cursor()
    cur.execute("SELECT * FROM payments WHERE member_id = %s", (session.get('client_id'),))
    payments = cur.fetchall()
    cur.close()
    return render_template("payment_list.html", payments=payments)

@app.route("/user_registration", methods=['GET', 'POST'])
def nobuk_user_registration():
    newUser = user_registration()
    
    if newUser.validate_on_submit():
        hashpee = bcrypt.generate_password_hash(newUser.password.data).decode('utf-8')
        cur = conn.cursor()
        cur.execute("""INSERT INTO clients(firstname, surname, email, password, buying_user, selling_user)
                    VALUES(%s, %s, %s, %s, %s, %s );""", (newUser.firstname.data, newUser.surname.data,
                    newUser.email.data, hashpee, newUser.buying_user.data, newUser.selling_user.data))
        conn.commit()
        flash(f'Your account was created successfully! You can now login', 'lightgreen')
        return redirect(url_for('nobuk_login'))

    return render_template("user_registration.html", title='Create Account', form=newUser)

@app.route("/login", methods=['GET', 'POST'])
def nobuk_login():
    login = user_login()
    
    if login.validate_on_submit():
        cur = conn.cursor()
        cur.execute("SELECT id, surname, email, password FROM clients;")
        clients = cur.fetchall()
        for client_id, surname, email, password in clients:
            if email == login.email.data and bcrypt.check_password_hash(password, login.password.data):
                flash(f'Succesful Login!', 'lightgreen')
                session['client_id'] = client_id
                return redirect(url_for('nobuk_home'))
        flash(f'Incorrect email or password', 'red')
        cur.close()
    return render_template("login.html", form=login, title='Login')

@app.route("/logout")
def nobuk_logout():
    session.pop('client_id', None)
    return redirect(url_for("nobuk_home"))

@app.route("/profile", methods=['GET', 'POST'])
def nobuk_profile():
    if not session.get('client_id'):
        flash('you must be logged in to see your account', 'rgba(255, 0, 0, .8)')
        return redirect(url_for('nobuk_login'))
    else:
        prof_pic = 'default.jpg'
        if request.method == "POST":
            hexedPicName = secrets.token_hex(8)
            if (request.files.get('prof_pic')):
                pic = request.files.get('prof_pic')
                _, file_ext = os.path.splitext(pic.filename)
                pic_path = os.path.join(app.root_path, 'static/images', f'{hexedPicName}{file_ext}')
                
                resize = (125, 125)
                pic = Image.open(pic)
                pic.thumbnail(resize)
                pic.save(pic_path)
        return render_template("profile.html", user=session.get('client_id'), prof_pic=prof_pic)

# Background Scheduler for Automated Reminders
def send_reminders():
    with app.app_context():
        cur = conn.cursor()
        cur.execute("SELECT * FROM payments WHERE status = 'PENDING'")
        pending_payments = cur.fetchall()
        for payment in pending_payments:
            # Send reminder logic here
        cur.close()

scheduler = BackgroundScheduler()
scheduler.add_job(func=send_reminders, trigger="interval", minutes=60)
scheduler.start()

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
