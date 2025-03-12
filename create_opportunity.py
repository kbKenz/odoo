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
    # Basic Contact Information
    contact_name=None,
    email_from=None,
    phone=None,
    mobile=None,
    partner_name=None,  # Company name
    function=None,  # Job position
    title=None,  # Contact title (Mr., Mrs., etc.)
    website=None,
    # Address Information
    street=None,
    street2=None,
    city=None,
    state_id=None,  # State database ID
    zip=None,
    country_id=None,  # Country database ID
    # Opportunity Details
    description=None,  # Internal notes
    priority=None,  # '0' = Normal, '1' = Low, '2' = High, '3' = Very High
    date_deadline=None,  # Expected closing date
    tag_ids=None,  # List of tag IDs
    probability=None,  # Win probability percentage (0-100)
    type="opportunity",  # 'lead' or 'opportunity'
    # Sales Information
    team_id=None,  # Sales team ID
    user_id=None,  # Salesperson ID
    company_id=None,  # Company ID
    stage_id=None,  # Stage ID in pipeline
    # Marketing Information
    campaign_id=None,  # UTM Campaign ID
    source_id=None,  # UTM Source ID
    medium_id=None,  # UTM Medium ID
    referred=None,  # Referred by
    active=True,  # Whether the opportunity is active
):
    """
    Create a new opportunity in Odoo with the given parameters
    All parameters except opportunity_name and expected_revenue are optional
    """
    # Create the lead/opportunity
    opportunity_data = {
        "type": type,
        "name": opportunity_name,
        "expected_revenue": float(expected_revenue),
    }

    # Basic Contact Information
    if contact_name:
        opportunity_data["contact_name"] = contact_name
    if email_from:
        opportunity_data["email_from"] = email_from
    if phone:
        opportunity_data["phone"] = phone
    if mobile:
        opportunity_data["mobile"] = mobile
    if partner_name:
        opportunity_data["partner_name"] = partner_name
    if function:
        opportunity_data["function"] = function
    if title:
        opportunity_data["title"] = title
    if website:
        opportunity_data["website"] = website

    # Address Information
    if street:
        opportunity_data["street"] = street
    if street2:
        opportunity_data["street2"] = street2
    if city:
        opportunity_data["city"] = city
    if state_id:
        opportunity_data["state_id"] = state_id
    if zip:
        opportunity_data["zip"] = zip
    if country_id:
        opportunity_data["country_id"] = country_id

    # Opportunity Details
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

    # Sales Information
    if team_id:
        opportunity_data["team_id"] = team_id
    if user_id:
        opportunity_data["user_id"] = user_id
    if company_id:
        opportunity_data["company_id"] = company_id
    if stage_id:
        opportunity_data["stage_id"] = stage_id

    # Marketing Information
    if campaign_id:
        opportunity_data["campaign_id"] = campaign_id
    if source_id:
        opportunity_data["source_id"] = source_id
    if medium_id:
        opportunity_data["medium_id"] = medium_id
    if referred:
        opportunity_data["referred"] = referred

    opportunity_data["active"] = active

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

        # Get default sales team
        sales_team_id = models.execute_kw(
            db, uid, password, "crm.team", "search", [[]], {"limit": 1}
        )

        # Example matching "Quote for 600 Chairs" format
        create_opportunity(
            opportunity_name="Quote for 599 Chairs",
            expected_revenue=123.99,
            tag_ids=tag_ids,  # Add Product tag
            team_id=(
                sales_team_id[0] if sales_team_id else None
            ),  # Assign to default sales team
            probability=75.0,  # Set probability to 75%
            type="opportunity",  # Make sure it's created as an opportunity
            priority="1",  # Priority level
            description="Large order for office chairs",  # Description
            partner_name="Acme Corporation",  # Customer name
            street="123 Business Ave",  # Street address
            street2="Suite 100",  # Street 2
            city="Springfield",  # City
            state_id=1,  # Example state ID
            zip="12345",  # ZIP code
            country_id=235,  # Example country ID (e.g., USA)
            website="www.acmecorp.com",  # Website
            contact_name="John Smith",  # Contact person name
            function="Procurement",  # Job position
            phone="+1 555-0123",  # Phone
            mobile="+1 555-0124",  # Mobile
            email_from="john.smith@acmecorp.com",  # Email
            company_id=1,  # Example company ID
            stage_id=1,  # Example stage ID
            campaign_id=1,  # Example campaign ID
            source_id=1,  # Example source ID
            medium_id=1,  # Example medium ID
            referred=True,  # Referred status
            active=True,  # Active status
        )

    except Exception as e:
        print(f"Error: {str(e)}")
