### The IRBEM-LIB Python3 wrapper ###
# Only tested on Linux and Python > 3.6
# To install in linux, run: "python3 -m pip install -e ."

from setuptools import setup

setup(name = 'IRBEM',
    description = 'Python wrapper for IRBEM',
    author = 'Mykhaylo Shumko',
    author_email = 'msshumko@gmail.com',
    url = 'https://sourceforge.net/projects/irbem/',
    version = '0.1.0',
    packages = ['IRBEM'],
    install_requires = ['wheel', 'python-dateutil', 
                        'numpy >= 1.12', 'scipy >= 0.14']
    )
