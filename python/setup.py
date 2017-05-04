# setup.py
from setuptools import setup, find_packages

# To install in linux, type in terminal "sudo python3 setup.py install"

# For developer install, use "sudo python setup.py develop" to install 
# and "sudo python3 setup.py develop -u" to remove. Note that you can 
# install the Python wrapper on Python 2.7 and Python 3.X.

setup(name = 'IRBEM',
    description = 'Python2/3 wrapper for IRBEM',
    author = 'Mykhaylo Shumko',
    author_email = 'msshumko@gmail.com',
    url = 'https://sourceforge.net/projects/irbem/',
    version = '0.1.0',
    packages = find_packages(),
    install_requires = ['numpy >= 1.12', 'scipy >= 0.14']
    )
