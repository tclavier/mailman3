from debian
env DEBIAN_FRONTEND noninteractive
run apt-get update && apt-get dist-upgrade && apt-get clean
run apt-get update && apt-get install -y bzr python3-dev python3-pip python-dev python-pip python-virtualenv && apt-get clean
run apt-get update && apt-get install -y nodejs nodejs-legacy npm && apt-get clean
run npm install -g less

# supervisord avec le plugin stdout
run apt-get update && \
    apt-get install -y supervisor && \
    pip install supervisor-stdout &&\
    apt-get clean
add supervisor.conf /etc/supervisor/conf.d/deliverous.conf    

run mkdir /mailman3 && cd /mailman3 && bzr branch lp:mailman-bundler
workdir /mailman3/mailman-bundler
run pip install zc.buildout && buildout
run virtualenv venv && . venv/bin/activate

expose 8000

# initialize Django’s database
run ./bin/mailman-post-update
# create an initial superuser to login
run ./bin/mailman-web-django-admin createsuperuser

cmd ["/usr/bin/supervisord"]
