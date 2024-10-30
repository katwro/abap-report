# Z_FLIGHT_PAYMENT_REPORT

## Description
The ABAP report `Z_FLIGHT_PAYMENT_REPORT` displays detailed flight information and calculates total payment amounts for each carrier. The report allows filtering data by carrier ID and flight date.

## Features
- **Data Filtering** - Filter results by carrier ID and flight date.
- **Detailed View** - Interactive display of detailed information for selected flights.
- **Payment Summation** - Summarizes payment amounts for each carrier, showing the total payment, carrier name, and currency.

## Structure
The report uses the following tables:
- **SFLIGHT** - Stores flight data, including carrier ID, flight date, price, and payment amount.
- **SPFLI** - Stores route information, including departure and destination cities.
- **SCARR** - Stores carrier information, including carrier name and currency code.

## Code Sections
1. **SELECTION-SCREEN** - Allows users to select carrier ID and flight date.
2. **FETCH_DATA** - Retrieves data from `SFLIGHT`, `SPFLI`, and `SCARR` tables based on selected criteria.
3. **DISPLAY_DATA** - Displays a list of flights along with the total payment for each carrier.
4. **DISPLAY_DETAILS** - Shows detailed information for a selected flight.

## Usage
1. Select a carrier ID (optional) and a date range (optional) on the selection screen.
2. Run the report.
3. Click on a specific flight line to view detailed information.

## Requirements
- SAP system with data in `SFLIGHT`, `SPFLI`, and `SCARR` tables.
- Authorization to execute ABAP reports in the system.

## License
This project is licensed under the MIT License.