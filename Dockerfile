# Use a lightweight Debian-based image
FROM debian:latest

# Set environment variables
ENV ODOO_VERSION=18.0 \
    ODOO_USER=odoo \
    ODOO_HOME=/opt/odoo \
    VIRTUAL_ENV=/opt/odoo/.venv  

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 python3-venv python3-pip python3-dev python3-setuptools \
    libxml2-dev libxslt1-dev \
    libjpeg-dev libpq-dev libffi-dev libssl-dev \
    git wget curl nano \
    node-less node-clean-css npm \
    wkhtmltopdf \
    # Add these lines:
    build-essential gcc \
    libldap2-dev libsasl2-dev \
    && rm -rf /var/lib/apt/lists/*

# Create Odoo user
RUN useradd -m -d $ODOO_HOME -U -r -s /bin/bash $ODOO_USER

# Set working directory
WORKDIR $ODOO_HOME

# Copy the Odoo source code
COPY . $ODOO_HOME

# Change ownership to Odoo user
RUN chown -R $ODOO_USER:$ODOO_USER $ODOO_HOME

# Switch to Odoo user
USER $ODOO_USER

# Create a virtual environment & install dependencies
RUN python3 -m venv $VIRTUAL_ENV && \
    $VIRTUAL_ENV/bin/pip install --no-cache-dir -r requirements.txt

# Set virtual environment path
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Expose ports
EXPOSE 8069 8072

# Run Odoo with the virtual environment
CMD ["python3", "/opt/odoo/odoo-bin", "--addons-path=/opt/odoo/addons"]
