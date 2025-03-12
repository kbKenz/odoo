FROM odoo:18.0

USER root

# Install pip and Faker
RUN apt-get update && apt-get install -y python3-pip \
    && pip3 install --break-system-packages Faker==19.13.0

# Set up proper permissions for filestore and other directories
RUN mkdir -p /var/lib/odoo/.local/share/Odoo/filestore \
    && chown -R odoo:odoo /var/lib/odoo \
    && chmod -R 777 /var/lib/odoo \
    && mkdir -p /usr/lib/python3/dist-packages/odoo/addons/base/static/img/lang_flags \
    && chown -R odoo:odoo /usr/lib/python3/dist-packages/odoo/addons/base/static \
    && chown -R odoo:odoo /var/lib/odoo

USER odoo 