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


def create_opportunity(contact_name, opportunity_name, email, phone, expected_revenue):
    """
    Create a new opportunity in Odoo with the given parameters
    """
    # Create the lead/opportunity
    opportunity_data = {
        "type": "opportunity",  # This makes it an opportunity instead of a lead
        "name": opportunity_name,  # This is the Opportunity name (e.g. "Product Pricing")
        "contact_name": contact_name,  # Contact name
        "email_from": email,  # Email address
        "phone": phone,  # Phone number
        "expected_revenue": float(expected_revenue),  # Expected revenue amount
    }

    try:
        opportunity_id = models.execute_kw(
            db, uid, password, "crm.lead", "create", [opportunity_data]
        )
        print(f"Successfully created opportunity with ID: {opportunity_id}")
        return opportunity_id
    except Exception as e:
        print(f"Error creating opportunity: {str(e)}")
        return None


if __name__ == "__main__":
    # Example usage
    contact_name = "John Doe"
    opportunity_name = "Product Pricing"
    email = "email@address.com"
    phone = "0123456789"
    expected_revenue = 3.00  # This is in the company's currency

    create_opportunity(
        contact_name=contact_name,
        opportunity_name=opportunity_name,
        email=email,
        phone=phone,
        expected_revenue=expected_revenue,
    )
