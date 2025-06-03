from setuptools import find_packages
from setuptools import setup

setup(
    name="DELL_S2725HS",
    version="0.0.1",
    url="https://github.com/SalmanKarim42/dells2725hs",
    author="Salman Karim",
    description="Use your Dell S2725HS as a Display.",
    packages=find_packages(),
    include_package_data=True,
    install_requires=["eventlet", "Flask", "Flask-SocketIO", "Flask-WTF"],
    entry_points={"console_scripts": ["dells2725hs = app.main:main"]},
)
