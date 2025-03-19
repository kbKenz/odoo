# Use a lightweight Debian-based image
FROM debian:latest

# Set environment variables
ENV ODOO_VERSION=18.0 \
    ODOO_USER=odoo \
    ODOO_HOME=/opt/odoo \
    VIRTUAL_ENV=/opt/odoo/.venv \
    PATH="/opt/odoo/.venv/bin:$PATH"

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 python3-venv python3-pip python3-dev python3-setuptools \
    libxml2-dev libxslt1-dev \
    libjpeg-dev libpq-dev libffi-dev libssl-dev \
    git wget curl nano \
    node-less node-clean-css npm \
    build-essential gcc \
    libldap2-dev libsasl2-dev \
    postgresql-client \
    xfonts-base xfonts-75dpi \
    && rm -rf /var/lib/apt/lists/*

# Install wkhtmltopdf for PDF reports
RUN wget -q https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6-1/wkhtmltox_0.12.6-1.buster_amd64.deb && \
    dpkg -i wkhtmltox_0.12.6-1.buster_amd64.deb && \
    apt-get install -f -y && \
    rm wkhtmltox_0.12.6-1.buster_amd64.deb

# Create Odoo user
RUN useradd -m -d $ODOO_HOME -U -r -s /bin/bash $ODOO_USER

# Set working directory
WORKDIR $ODOO_HOME

# Copy Odoo source code
COPY . $ODOO_HOME

# Change ownership
RUN chown -R $ODOO_USER:$ODOO_USER $ODOO_HOME

# Switch to Odoo user
USER $ODOO_USER

# Create a virtual environment & install dependencies
RUN python3 -m venv $VIRTUAL_ENV && \
    pip install --no-cache-dir -r requirements.txt

# Expose necessary ports
EXPOSE 8080

# Set entrypoint command
CMD ["python3", "/opt/odoo/odoo-bin", "--addons-path=/opt/odoo/addons"]
