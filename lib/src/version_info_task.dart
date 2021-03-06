import 'dart:io' show Directory, File;
import 'package:grinder/grinder.dart' show getFile;
import 'package:pub_semver/pub_semver.dart' show Version;
import 'package:yaml/yaml.dart' show loadYaml;
import 'package:path/path.dart' as path;

typedef VersionFileTemplate = String Function(String version);

String versionFileTemplate(String version) => '''
const String packageVersion  = \'$version\';
final DateTime packageVersionDate =
    DateTime.parse('${DateTime.now().toUtc().toIso8601String()}');

DateTime get _versionDate => packageVersionDate.toLocal();
String _versionDateString;
String get packageVersionDateString => _versionDateString ??=
    '\${_versionDate.year}-\${_versionDate.month.toString().padLeft(2, '0')}'
    '-\${_versionDate.day.toString().padLeft(2, '0')}'
    ' \${_versionDate.hour.toString().padLeft(2, '0')}:'
    '\${_versionDate.minute.toString().padLeft(2, '0')}';

    ''';

/// Write the package version into a Dart source file
void writeVersionInfoFile(
    {String versionFilePath = 'lib/src/version_info.dart',
    VersionFileTemplate versionFileTemplate = versionFileTemplate}) {
  assert(versionFilePath != null && versionFilePath.endsWith('.dart'));
  // Read the version from the pubspec.
  final pubspecFile = getFile('pubspec.yaml');
  final pubspec = pubspecFile.readAsStringSync();
  final version = Version.parse(loadYaml(pubspec)['version'] as String);
  Directory(path.dirname(versionFilePath)).createSync(recursive: true);
  File(versionFilePath).writeAsStringSync(versionFileTemplate('$version'));
}
