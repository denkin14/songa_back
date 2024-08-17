from flask import Blueprint, render_template, redirect, url_for, flash, session, request
from app import db
from app.forms import UserRegistrationForm, UserLoginForm, GroupCreationForm, PaymentLinkForm
from app.models import Client, Group, PaymentLink

main = Blueprint('main', __name__)

@main.route("/home")
def home():
    return render_template("home.html", user=session.get('client_id'))

@main.route("/create_group", methods=['GET', 'POST'])
def create_group():
    form = GroupCreationForm()
    if form.validate_on_submit():
        new_group = Group(name=form.name.data, description=form.description.data, admin_id=session['client_id'])
        db.session.add(new_group)
        db.session.commit()
        flash('Group created successfully!', 'success')
        return redirect(url_for('main.home'))
    return render_template("group_creation.html", form=form)

@main.route("/create_payment_link", methods=['GET', 'POST'])
def create_payment_link():
    form = PaymentLinkForm()
    if form.validate_on_submit():
        new_link = PaymentLink(group_id=1, link="generated_link_here", amount=form.amount.data,
                               currency=form.currency.data, notification_email=form.notification_email.data, link_status=True)
        db.session.add(new_link)
        db.session.commit()
        flash('Payment link created successfully!', 'success')
        return redirect(url_for('main.home'))
    return render_template("payment_link.html", form=form)

@main.route("/login", methods=['GET', 'POST'])
def login():
    form = UserLoginForm()
    if form.validate_on_submit():
        user = Client.query.filter_by(email=form.email