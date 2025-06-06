import flask

import db.settings
import hostname
import update.settings
from find_files import find as find_files

views_blueprint = flask.Blueprint('views', __name__, url_prefix='')

# Default hostname of DELL_S2725HS device.
_DEFAULT_HOSTNAME = 'dells2725hs'


@views_blueprint.route('/', methods=['GET'])
def index_get():
    use_webrtc = db.settings.Settings().get_streaming_mode(
    ) == db.settings.StreamingMode.H264

    try:
        update_settings = update.settings.load()
    except update.settings.LoadSettingsError:
        return flask.abort(500)

    return flask.render_template(
        'index.html',
        is_debug=flask.current_app.debug,
        use_webrtc_remote_screen=use_webrtc,
        janus_stun_server=update_settings.janus_stun_server,
        janus_stun_port=update_settings.janus_stun_port,
        page_title_prefix=_page_title_prefix(),
        is_standalone_mode=_is_standalone_mode(),
        custom_elements_files=find_files.custom_elements_files())


# The style guide is for development purpose only, so we don’t ship it to
# end users.
@views_blueprint.route('/styleguide', methods=['GET'])
def styleguide_get():
    if flask.current_app.debug:
        return flask.render_template(
            'styleguide.html',
            custom_elements_files=find_files.custom_elements_files())
    return flask.abort(404)


@views_blueprint.route('/dedicated-window-placeholder', methods=['GET'])
def dedicated_window_placeholder_get():
    return flask.render_template('dedicated-window-placeholder.html',
                                 page_title_prefix=_page_title_prefix())


# On a real install, nginx redirects the /stream route to uStreamer, so a real
# user should never hit this route in production. In development, show a fake
# still image to give a better sense of how the DELL_S2725HS UI looks.
@views_blueprint.route('/stream', methods=['GET'])
def stream_get():
    if flask.current_app.debug:
        return flask.send_file('testdata/test-remote-screen.jpg')
    return flask.abort(404)


def _page_title_prefix():
    if hostname.determine().lower() != _DEFAULT_HOSTNAME.lower():
        return f'{hostname.determine()} - '
    return ''


def _is_standalone_mode():
    return flask.request.args.get('viewMode') == 'standalone'
