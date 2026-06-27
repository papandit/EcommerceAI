import 'package:get/get.dart';

import 'package:EcommerceApp/model/ligalpolicymodel.dart';

class LegalPolicyController extends GetxController {
  LegalPolicy? legalPolicy;
  bool isLoader = false;
  String getLegalPolicy = """<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Legal Policies - E-com Fashion</title>
  <style>
    body {
      font-family: Arial, sans-serif;
      line-height: 1.6;
      margin: 20px;
      padding: 20px;
      background-color: #f9f9f9;
      color: #333;
    }
    h1, h2, h3 {
      color: #2c3e50;
    }
    h1 {
      text-align: center;
    }
    ul {
      margin-left: 20px;
    }
    a {
      color: #3498db;
      text-decoration: none;
    }
    a:hover {
      text-decoration: underline;
    }
  </style>
</head>
<body>
  <h1>E-com Fashion Legal Policies</h1>

  <h2>1. Introduction</h2>
  <p>Welcome to E-com Fashion! Shopping with us means you agree to the policies below, ensuring a seamless and stylish experience.</p>

  <h2>2. Privacy Policy</h2>
  <p>Your privacy is our priority. We collect:</p>
  <ul>
    <li>Your name, email, and shipping details for order fulfillment.</li>
    <li>Secure payment details for transactions.</li>
    <li>Cookies to personalize your shopping experience.</li>
  </ul>
  <p>For details, read our <a href="/privacy-policy.html">Privacy Policy</a>.</p>

  <h2>3. Terms and Conditions</h2>
  <p>By shopping with us, you agree to:</p>
  <ul>
    <li>Provide accurate information.</li>
    <li>Avoid fraudulent activities.</li>
    <li>Respect our brand identity, content, and designs.</li>
  </ul>
  <p>Read the full <a href="/terms-and-conditions.html">Terms and Conditions</a>.</p>

  <h2>4. Refund and Cancellation Policy</h2>
  <p>We want you to love your purchase! If not, we offer:</p>
  <ul>
    <li>Order cancellations before shipping for a full refund.</li>
    <li>Returns within 7 days for eligible items.</li>
    <li>Non-returnable items: Innerwear, custom orders, and clearance items.</li>
  </ul>
  <p>Check our <a href="/refund-policy.html">Refund Policy</a> for details.</p>

  <h2>5. Shipping Policy</h2>
  <p>We deliver fashion to your doorstep:</p>
  <ul>
    <li>Standard delivery: 3-7 business days within India.</li>
    <li>Free shipping on orders above ₹999.</li>
    <li>Possible delays due to unforeseen factors.</li>
  </ul>
  <p>Find more details in our <a href="/shipping-policy.html">Shipping Policy</a>.</p>

  <h2>6. Payment Policy</h2>
  <p>Secure and hassle-free payments via credit/debit cards, UPI, and wallets. Transactions are encrypted for safety. Need help? Contact support.</p>

  <h2>7. Liability Disclaimer</h2>
  <p>E-com Fashion is not responsible for:</p>
  <ul>
    <li>Delays beyond our control.</li>
    <li>Site unavailability or minor errors.</li>
  </ul>

  <h2>8. Governing Law and Jurisdiction</h2>
  <p>All disputes fall under the jurisdiction of [Your City], India.</p>

  <h2>9. Contact Information</h2>
  <p>Need help? Reach out to us:</p>
  <ul>
    <li>Email: <a href="mailto:support@ecomfashion.com">support@ecomfashion.com</a></li>
    <li>Phone: +91-XXXXXXXXXX</li>
  </ul>

  <p>Happy Shopping with E-com Fashion!</p>
</body>
</html> """;
}
