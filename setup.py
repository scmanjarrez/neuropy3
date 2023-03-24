#!/usr/bin/env python3

# SPDX-License-Identifier: GPL-3.0-or-later

# setup - package setup.

# Copyright (C) 2022-2023 Sergio Chica Manjarrez @ pervasive.it.uc3m.es.
# Universidad Carlos III de Madrid.

# This file is part of neuropy3.

# neuropy3 is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# neuropy3 is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

from setuptools import setup
from pathlib import Path

_parent = Path(__file__).parent.resolve()
readme = (_parent / 'README.md').read_text(encoding='utf-8')


setup(
    name='neuropy3',
    version='1.0.4',
    description=('Python3 library to read data from '
                 'Neurosky Mindwave Mobile 2 in linux.'),
    author='Sergio Chica',
    author_email='sergio.chica@uc3m.es',
    long_description=readme,
    long_description_content_type='text/markdown',
    keywords=[
        'eeg',
        'neurosky',
        'mindwave',
        'neurosky mindwave mobile 2'
    ],
    url='https://gitlab.gast.it.uc3m.es/schica/neuropy3',
    license='GPLv3+',
    license_files=['LICENSE'],
    classifiers=[
        ('License :: OSI Approved :: '
         'GNU General Public License v3 or later (GPLv3+)'),
        'Programming Language :: Python :: 3',
        'Programming Language :: Python :: 3.8'
    ],
    packages=['neuropy3', 'neuropy3.gui'],
    python_requires='>= 3.8',
    install_requires=[
        'pybluez2==0.46',
        'numpy==1.23.3',
        'scipy==1.9.1'
    ],
    extras_require={
        'gui': ['PySide6==6.2.3', 'shiboken6==6.2.3']
    },
    entry_points={
        'console_scripts': [
            'neuropy=neuropy3.__main__:main'
        ]
    }
)
