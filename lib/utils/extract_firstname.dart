// Example function to extract the first name from the full name.
String getFirstName({required String fullName}) {
  List<String> nameParts = fullName.split(' '); // Split by space
  String firstName = nameParts[0]; // Get the first part
  return firstName.trim(); // Remove leading and trailing spaces (if any)
}