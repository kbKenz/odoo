#!/usr/bin/env python3
import xmlrpc.client
from datetime import datetime, timedelta


# Odoo connection parameters
url = "https://odoo-service-424143850578.us-central1.run.app"
db = "testdb"
username = "kenzhebaevbektur@gmail.com"
password = "kenzhebaevbektur@gmail.com"

# Connect to Odoo
common = xmlrpc.client.ServerProxy(f"{url}/xmlrpc/2/common")
uid = common.authenticate(db, username, password, {})
models = xmlrpc.client.ServerProxy(f"{url}/xmlrpc/2/object")


def create_opportunity(
    opportunity_name,
    expected_revenue,
    contact_name=None,
    email=None,
    phone=None,
    description=None,
    priority=None,  # '0' = Normal, '1' = Low, '2' = High, '3' = Very High
    date_deadline=None,  # Expected closing date
    tag_ids=None,
    probability=None,  # Win probability percentage (0-100)
):
    """
    Create a new opportunity in Odoo with the given parameters
    All parameters except opportunity_name and expected_revenue are optional
    """
    # Create the lead/opportunity
    opportunity_data = {
        "type": "opportunity",  # This makes it an opportunity instead of a lead
        "name": opportunity_name,  # This is the Opportunity name
        "expected_revenue": float(expected_revenue),  # Expected revenue amount
    }

    # Add optional fields if provided
    if contact_name:
        opportunity_data["contact_name"] = contact_name
    if email:
        opportunity_data["email_from"] = email
    if phone:
        opportunity_data["phone"] = phone
    if description:
        opportunity_data["description"] = description
    if priority:
        opportunity_data["priority"] = priority
    if date_deadline:
        opportunity_data["date_deadline"] = date_deadline
    if tag_ids:
        opportunity_data["tag_ids"] = [(6, 0, tag_ids)]
    if probability is not None:
        opportunity_data["probability"] = float(probability)

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
    # First, let's find or create the "Product" tag
    try:
        # Search for existing "Product" tag
        tag_ids = models.execute_kw(
            db, uid, password, "crm.tag", "search", [[("name", "=", "Product")]]
        )

        if not tag_ids:
            # Create "Product" tag if it doesn't exist
            tag_id = models.execute_kw(
                db, uid, password, "crm.tag", "create", [{"name": "Product"}]
            )
            tag_ids = [tag_id]

        # Example with all optional fields
        opportunity_name = "Quote for 599 Chairs"
        expected_revenue = 22312.50

        # Example of creating an opportunity with all optional fields
        create_opportunity(
            opportunity_name=opportunity_name,
            expected_revenue=expected_revenue,
            contact_name="John Smith",  # Optional: Contact name
            email="john.smith@example.com",  # Optional: Email
            phone="+1234567890",  # Optional: Phone
            description="Client needs 599 chairs for their new office space.\nRequested delivery by end of month.",  # Optional: Internal notes
            priority="2",  # Optional: High priority
            date_deadline=(datetime.now() + timedelta(days=30)).strftime(
                "%Y-%m-%d"
            ),  # Optional: Expected closing in 30 days
            tag_ids=tag_ids,  # Optional: Tags
            probability=75.0,  # Optional: 75% chance of winning
        )

        # Example of creating an opportunity with minimal fields
        create_opportunity(
            opportunity_name="Basic Quote for Chairs",
            expected_revenue=22312.50,
            # No optional fields
        )

    except Exception as e:
        print(f"Error: {str(e)}")
