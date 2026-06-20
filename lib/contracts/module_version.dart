/// Semantic version for modules and shell.
///
/// Follows MAJOR.MINOR.PATCH convention.
class ModuleVersion implements Comparable<ModuleVersion> {
  final int major;
  final int minor;
  final int patch;

  const ModuleVersion(this.major, this.minor, this.patch);

  String get asString => '$major.$minor.$patch';

  @override
  int compareTo(ModuleVersion other) {
    final majorCmp = major.compareTo(other.major);
    if (majorCmp != 0) return majorCmp;
    final minorCmp = minor.compareTo(other.minor);
    if (minorCmp != 0) return minorCmp;
    return patch.compareTo(other.patch);
  }

  bool operator >=(ModuleVersion other) => compareTo(other) >= 0;
  bool operator <=(ModuleVersion other) => compareTo(other) <= 0;
  bool operator >(ModuleVersion other) => compareTo(other) > 0;
  bool operator <(ModuleVersion other) => compareTo(other) < 0;

  /// Whether this version satisfies a [min] and optional [max] constraint.
  bool satisfies({required ModuleVersion min, ModuleVersion? max}) {
    if (this < min) return false;
    if (max != null && this > max) return false;
    return true;
  }

  @override
  bool operator ==(Object other) =>
      other is ModuleVersion &&
      other.major == major &&
      other.minor == minor &&
      other.patch == patch;

  @override
  int get hashCode => Object.hash(major, minor, patch);

  @override
  String toString() => 'ModuleVersion($asString)';
}
