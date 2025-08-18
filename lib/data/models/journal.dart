import 'package:json_annotation/json_annotation.dart';

part 'journal.g.dart';

@JsonSerializable()
class Journal {
  final String id;

  @JsonKey(name: 'siswa_nisn')
  final String siswaNisn;

  final String tanggal;
  final String kegiatan;
  final String? target;

  Journal({
    required this.id,
    required this.siswaNisn,
    required this.tanggal,
    required this.kegiatan,
    this.target,
  });

  factory Journal.fromJson(Map<String, dynamic> json) =>
      _$JournalFromJson(json);
  Map<String, dynamic> toJson() => _$JournalToJson(this);
}
