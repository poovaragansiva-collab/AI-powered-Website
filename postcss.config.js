/*
  # Fix overly permissive RLS policies

  1. Security Changes
    - Remove overly permissive "INSERT" policies with "WITH CHECK (true)"
    - Add restrictive policies that validate data before insertion
    - Bookings: Allow insertions for public access with required field validation
    - Contact messages: Allow insertions for public access with required field validation
    - Both tables still allow public reads to maintain functionality

  2. Updated Policies
    - Bookings: Now requires valid name and phone before insertion
    - Contact messages: Now requires valid email format and name/message before insertion
*/

DROP POLICY IF EXISTS "Anyone can create bookings" ON bookings;
DROP POLICY IF EXISTS "Anyone can create contact messages" ON contact_messages;

CREATE POLICY "Public can create bookings with valid data"
  ON bookings
  FOR INSERT
  TO public
  WITH CHECK (
    name IS NOT NULL AND
    TRIM(name) != '' AND
    phone IS NOT NULL AND
    TRIM(phone) != '' AND
    service_type IS NOT NULL AND
    pickup_date IS NOT NULL AND
    delivery_date IS NOT NULL AND
    delivery_date >= (pickup_date + INTERVAL '3 days')
  );

CREATE POLICY "Public can create contact messages with valid data"
  ON contact_messages
  FOR INSERT
  TO public
  WITH CHECK (
    name IS NOT NULL AND
    TRIM(name) != '' AND
    email IS NOT NULL AND
    TRIM(email) != '' AND
    email ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}$' AND
    message IS NOT NULL AND
    TRIM(message) != ''
  );
