**GreenTrans (TMS) replaces scattered calls, spreadsheets and paperwork with one web platform where customers book shipments, drivers deliver them, and managers and admins track everything in real time.**

# TMS — GreenTrans Transport Management System

A role-based transport and logistics management web app for booking, tracking and delivering shipments, built with PHP and MySQL.

---

## Features

- **Four user roles:** Customer, Driver, Manager and Admin, each with their own dashboard
- **Shipment booking and live tracking** with unique tracking IDs (e.g. `GT2026xxxx`)
- **Driver onboarding:** document upload (ID proof, licence) and admin approval
- **Fleet management:** vehicles, driver assignment and driver availability
- **Invoices and earnings** for customers and drivers
- **Support tickets and complaints** with admin review
- **Secure authentication:** registration, login and OTP-based password reset by email
- **Notifications** for shipment and account updates
- **Analytics and reports** with charts, plus CSV export for admins and managers
- **Light / dark theme** and a responsive layout

## Tech Stack

| Layer     | Technology                                  |
| --------- | ------------------------------------------- |
| Backend   | PHP 8 (PDO, OOP classes)                    |
| Database  | MySQL / MariaDB                             |
| Frontend  | HTML, CSS, JavaScript, Bootstrap 5.3        |
| Charts    | Chart.js                                    |
| Email     | PHPMailer (SMTP)                            |
| Local env | XAMPP (Apache + MySQL)                      |

## Installation

### Prerequisites

- [XAMPP](https://www.apachefriends.org/) (or any Apache + PHP 8 + MySQL stack)
- Git

### Steps

1. **Clone the repository**

   ```bash
   git clone https://github.com/opakanksha16-hash/tms.git
   ```

2. **Place the project in your web root**

   Make sure the project folder is named `tms` and sits inside `C:\xampp\htdocs\`, so the final path is `C:\xampp\htdocs\tms`. (Easiest: run the clone command from inside `htdocs`.)

3. **Start Apache and MySQL** from the XAMPP Control Panel.

4. **Create the database**

   Open [phpMyAdmin](http://localhost/phpmyadmin), go to **Import**, and select `database/greentrans.sql`. This creates the `greentrans` database with all tables and demo data.

5. **Configure the app**

   - `config/database.php`: set `DB_HOST`, `DB_PORT`, `DB_USER` and `DB_PASS` to match your MySQL setup.
   - `config/config.php`: set `APP_URL` if your folder name or port is different.
   - `classes/Mailer.php`: replace the SMTP email and app password with your own so OTP emails can be sent.

## Running the Project

Open your browser and visit:

```
http://localhost/tms
```

### Demo accounts

All demo accounts use the password `password` (change these before any real deployment).

| Role     | Email                |
| -------- | -------------------- |
| Admin    | admin@gmail.com      |
| Manager  | manager@gmail.com    |
| Driver   | driver1@gmail.com    |
| Customer | customer@gmail.com   |

## Project Structure

```
├── admin/        # Admin pages
├── manager/      # Manager pages
├── driver/       # Driver pages
├── customer/     # Customer pages
├── auth/         # Login, register, OTP and password reset
├── api/          # AJAX endpoints and CSV export
├── classes/      # User, Shipment, Vehicle, Driver, Mailer, ...
├── config/       # App and database configuration
├── database/     # SQL schema and demo data
├── includes/     # Shared header, navbar, sidebar, footer
├── assets/       # CSS, JS and images
└── uploads/      # User-uploaded files
```

## Screenshots

| Landing Page | Customer Dashboard |
| ------------ | ------------------ |
| ![Landing Page](screenshots/landing.png) | ![Customer Dashboard](screenshots/customer-dashboard.png) |

| Admin Analytics | Shipment Tracking |
| --------------- | ----------------- |
| ![Admin Analytics](screenshots/admin-analytics.png) | ![Shipment Tracking](screenshots/tracking.png) |

> Add your images to a `screenshots/` folder in the repository and update the file names above.

## Author

**opakanksha16-hash** — [GitHub](https://github.com/opakanksha16-hash)
