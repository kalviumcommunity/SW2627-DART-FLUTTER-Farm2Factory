/// One farmer. Plain data only, no UI code here.
class Farmer {
  final String id; // e.g. F001
  final String name;
  final String phone;
  final String village;
  final String center; // collection center
  final String status; // Active / Inactive

  const Farmer({
    required this.id,
    required this.name,
    required this.phone,
    required this.village,
    required this.center,
    this.status = 'Active',
  });
}
