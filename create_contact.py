#!/usr/bin/env python3
import xmlrpc.client

# Odoo connection parameters
url = "https://odoo-service-424143850578.us-central1.run.app"
db = "testdb"
username = "kenzhebaevbektur@gmail.com"
password = "kenzhebaevbektur@gmail.com"

# Connect to Odoo
common = xmlrpc.client.ServerProxy(f"{url}/xmlrpc/2/common")
uid = common.authenticate(db, username, password, {})
models = xmlrpc.client.ServerProxy(f"{url}/xmlrpc/2/object")


def create_contact(
    # Basic Contact Information
    name,  # Required
    company_type="person",  # 'person' or 'company'
    email=None,
    phone=None,
    mobile=None,
    website=None,
    title=None,  # Contact title (Mr., Mrs., etc.)
    function=None,  # Job position
    # Address Information
    street=None,
    street2=None,
    city=None,
    state_id=None,  # State database ID
    zip=None,
    country_id=None,  # Country database ID
    # Additional Information
    comment=None,  # Internal notes
    parent_id=None,  # Parent company ID if this is a contact person
    user_id=None,  # Salesperson ID
    industry_id=None,  # Industry ID
    # Communication Settings
    lang=None,  # Language code
    active=True,  # Whether the contact is active
):
    """
    Create a new contact (res.partner) in Odoo with the given parameters
    Only name parameter is required, all others are optional
    """
    contact_data = {
        "name": name,
        "company_type": company_type,
        "is_company": company_type == "company",
    }

    # Basic Contact Information
    if email:
        contact_data["email"] = email
    if phone:
        contact_data["phone"] = phone
    if mobile:
        contact_data["mobile"] = mobile
    if website:
        contact_data["website"] = website
    if title:
        contact_data["title"] = title
    if function:
        contact_data["function"] = function

    # Address Information
    if street:
        contact_data["street"] = street
    if street2:
        contact_data["street2"] = street2
    if city:
        contact_data["city"] = city
    if state_id:
        contact_data["state_id"] = state_id
    if zip:
        contact_data["zip"] = zip
    if country_id:
        contact_data["country_id"] = country_id

    # Additional Information
    if comment:
        contact_data["comment"] = comment
    if parent_id:
        contact_data["parent_id"] = parent_id
    if user_id:
        contact_data["user_id"] = user_id
    if industry_id:
        contact_data["industry_id"] = industry_id
    if lang:
        contact_data["lang"] = lang

    contact_data["active"] = active

    try:
        contact_id = models.execute_kw(
            db, uid, password, "res.partner", "create", [contact_data]
        )
        print(f"Successfully created contact with ID: {contact_id}")
        return contact_id
    except Exception as e:
        print(f"Error creating contact: {str(e)}")
        return None


if __name__ == "__main__":
    try:
        # Example: Create a company contact
        company_id = create_contact(
            name="Bektur",
            company_type="company",
            email="info@acmecorp.com",
            phone="+1 555-0123",
            website="www.acmecorp.com",
            street="123 Business Ave",
            street2="Suite 100",
            city="Springfield",
            state_id=1,  # Example state ID
            zip="12345",
            country_id=235,  # Example country ID (e.g., USA)
            industry_id=1,  # Example industry ID
            comment="Large enterprise customer",
            user_id=1,  # Example salesperson ID
            lang="en_US",
            active=True,
        )

        # Example: Create a contact person for the company
        if company_id:
            create_contact(
                name="John Smith",
                company_type="person",
                email="john.smith@acmecorp.com",
                phone="+1 555-0124",
                mobile="+1 555-0125",
                function="Procurement Manager",
                title=1,  # Example title ID (Mr., Mrs., etc.)
                parent_id=company_id,  # Link to the company
                user_id=1,
                active=True,
            )

    except Exception as e:
        print(f"Error: {str(e)}")
