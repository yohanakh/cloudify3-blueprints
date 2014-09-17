__author__ = 'kobikis'
from setuptools import setup

PLUGINS_COMMON_VERSION = "3.0"
PLUGINS_COMMON_BRANCH = "develop"
PLUGINS_COMMON = "https://github.com/cloudify-cosmo/cloudify-plugins-common/tarball/{0}".format(PLUGINS_COMMON_BRANCH)

setup(
    zip_safe=True,
    name='xap-admin-plugin',
    version='0.1.0',
    author='kobikis',
    author_email='kobi@gigaspaces.com',
    packages=[
        'xap_admin_plugin'
    ],
    license='APACHE 2.0',
    description='Sample plugin for deploying/undeploying xap services.',
    install_requires=[
        "cloudify-plugins-common"
    ],
    dependency_links=["{0}#egg=cloudify-plugins-common-{1}".format(PLUGINS_COMMON, PLUGINS_COMMON_VERSION)] 
)
