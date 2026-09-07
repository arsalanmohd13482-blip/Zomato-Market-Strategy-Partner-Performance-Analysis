# Zomato Market Strategy & Partner Performance Analysis

This project analyzes Zomato's Indian restaurant ecosystem to identify strategic growth opportunities and isolate underperforming regional markets. By leveraging advanced SQL techniques, the analysis segments cities into actionable business tiers based on customer trust, pricing, and service adoption.

**Tech Stack & Methodologies**
* **Database:** PostgreSQL
* **Techniques:** Common Table Expressions (CTEs), Window Functions (`DENSE_RANK`, `NTILE`, `AVG() OVER PARTITION BY`), Conditional Aggregation.

**Key Business Insights**

* **Massive Delivery Under-Adoption in Major Hubs:** Despite being the highest-volume markets, the National Capital Region (NCR) shows surprisingly low online delivery adoption. New Delhi (5,473 restaurants) operates at only 27.2% delivery adoption, and Faridabad (251 restaurants) sits at just 13.9%. These represent Zomato's primary targets for "Growth Investment" to convert dine-in-only vendors into delivery partners.
* **Premium Features Drive Engagement:** Restaurants utilizing the "Table Booking" feature generate more than double the customer engagement, averaging 362 votes per restaurant compared to just 147 votes for those without it. Table booking also correlates with a higher average customer rating (3.55 vs 3.31). 
* **Partner Support Required in Noida and Faridabad:** Applying the City Opportunity Matrix revealed that over 21% of restaurants in both Noida and Faridabad maintain an aggregate rating below 3.0. These regions require immediate "Partner Quality Support" from Zomato account managers to address systemic customer trust issues.
