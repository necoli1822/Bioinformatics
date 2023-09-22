from setuptools import setup, find_packages
from comclibact.info import __package_name__, __version__

with open('README.md', 'r', encoding='utf-8') as f:
    readme = f.read()
with open("requirements.txt", "r") as f:
    requirements = f.read().splitlines()
with open("tset_requirements.txt", "r") as f:
    test_requirements = f.read().splitlines()

setup(
    name=__package_name__,
    version=__version__,
    long_description=readme,
    packages=find_packages(exclude=["contirb", "docs", "tests"]),
    package_data={'': ['*.yaml', '*.yml']},
    install_requires=requirements,
    setup_requires=['pytest-runner'],
    tests_require=test_requirements,
    python_requires=">3.8",
    entry_points={
        "console_scripts": ["comclibact=comclibact.main:main"]
    },
    classifiers=[
        'Environment :: Console',
        'Operating System :: POSIX :: Linux',
        'Programming Language :: Python :: 3.8'
    ]
)