"""
Production WSGI hook.
"""
from server.app import create_app

from dotenv import load_dotenv

# This is a temporary solution until config management
# (ideally through a helm-like mechanism) is set up.
# Load environment variables from the .env file.
# This must be done before the app is created.
load_dotenv()

# The application object that Gunicorn will find.
# create_app() returns a Connexion FlaskApp, so we need to access its .app property
# to get the underlying Flask application instance for WSGI.
application = create_app().app
