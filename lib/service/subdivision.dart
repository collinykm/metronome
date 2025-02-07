import "dart:core";
import "package:uuid/uuid.dart";

import 'package:hive_flutter/hive_flutter.dart';

part 'subdivision.g.dart'; // This will be generated

@HiveType(typeId: 2) // Unique typeId for Subdivision
class Subdivision {
  @HiveField(0)
  final String subdivisionId;

  @HiveField(1)
  final String imagePath;

  @HiveField(2)
  final List<int> subdivisionList;

  Subdivision({
    required this.imagePath,
    required this.subdivisionList,
  }) : subdivisionId = Uuid().v4();
}


Map<int, List<Subdivision>> allSubdivisionsMap = {
  2 : [
    Subdivision(imagePath: "$two/h.png", subdivisionList: [1, 1]),
    Subdivision(imagePath: "$two/q_q.png", subdivisionList: [2, 1, 1]),
    Subdivision(imagePath: "$two/qr_q.png", subdivisionList: [2, 0, 1]),
    Subdivision(imagePath: "$two/q_q_q.png", subdivisionList: [3, 1, 1, 1]),
    Subdivision(imagePath: "$two/q_qr_q.png", subdivisionList: [3, 1, 0, 1]),
    Subdivision(imagePath: "$two/q_q_qr.png", subdivisionList: [3, 1, 1, 0]),
    Subdivision(imagePath: "$two/qr_q_q.png", subdivisionList: [3, 0, 1, 1]),
    Subdivision(imagePath: "$two/qr_q_qr.png", subdivisionList: [3, 0, 1, 0]),
    Subdivision(imagePath: "$two/e_e_e_e.png", subdivisionList: [4, 1, 1, 1, 1]),
    Subdivision(imagePath: "$two/q_e_e.png", subdivisionList: [4, 1, 0, 1, 1]),
    Subdivision(imagePath: "$two/e_dq.png", subdivisionList: [4, 1, 1, 0, 0]),
    Subdivision(imagePath: "$two/e_q_e.png", subdivisionList: [4, 1, 1, 0, 1]),
    Subdivision(imagePath: "$two/dq_e.png", subdivisionList: [4, 1, 0, 0, 1]),
  ],
  4: [
    Subdivision(imagePath: "$four/q.png", subdivisionList: [1, 1]),
    Subdivision(imagePath: "$four/e_e.png", subdivisionList: [2, 1, 1]),
    Subdivision(imagePath: "$four/er_e.png", subdivisionList: [2, 0, 1]),
    Subdivision(imagePath: "$four/e_e_e.png", subdivisionList: [3, 1, 1, 1]),
    Subdivision(imagePath: "$four/e_er_e.png", subdivisionList: [3, 1, 0, 1]),
    Subdivision(imagePath: "$four/e_e_er.png", subdivisionList: [3, 1, 1, 0]),
    Subdivision(imagePath: "$four/er_e_e.png", subdivisionList: [3, 0, 1, 1]),
    Subdivision(imagePath: "$four/er_e_er.png", subdivisionList: [3, 0, 1, 0]),
    Subdivision(imagePath: "$four/s_s_s_s.png", subdivisionList: [4, 1, 1, 1, 1]),
    Subdivision(imagePath: "$four/e_s_s.png", subdivisionList: [4, 1, 0, 1, 1]),
    Subdivision(imagePath: "$four/s_de.png", subdivisionList: [4, 1, 1, 0, 0]),
    Subdivision(imagePath: "$four/s_e_s.png", subdivisionList: [4, 1, 1, 0, 1]),
    Subdivision(imagePath: "$four/de_s.png", subdivisionList: [4, 1, 0, 0, 1]),
  ],
  8: [
    Subdivision(imagePath: "$eight/e.png", subdivisionList: [1, 1]),
    Subdivision(imagePath: "$eight/s_s.png", subdivisionList: [2, 1, 1]),
    Subdivision(imagePath: "$eight/sr_s.png", subdivisionList: [2, 0, 1]),
    Subdivision(imagePath: "$eight/s_s_s.png", subdivisionList: [3, 1, 1, 1]),
    Subdivision(imagePath: "$eight/s_sr_s.png", subdivisionList: [3, 1, 0, 1]),
    Subdivision(imagePath: "$eight/s_s_sr.png", subdivisionList: [3, 1, 1, 0]),
    Subdivision(imagePath: "$eight/sr_s_s.png", subdivisionList: [3, 0, 1, 1]),
    Subdivision(imagePath: "$eight/sr_s_sr.png", subdivisionList: [3, 0, 1, 0]),
    Subdivision(imagePath: "$eight/t_t_t_t.png", subdivisionList: [4, 1, 1, 1, 1]),
    Subdivision(imagePath: "$eight/s_t_t.png", subdivisionList: [4, 1, 0, 1, 1]),
    Subdivision(imagePath: "$eight/t_ds.png", subdivisionList: [4, 1, 1, 0, 0]),
    Subdivision(imagePath: "$eight/t_s_t.png", subdivisionList: [4, 1, 1, 0, 1]),
    Subdivision(imagePath: "$eight/ds_t.png", subdivisionList: [4, 1, 0, 0, 1]),
  ]
};

String two = "assets/subdivision_images/2";
String four = "assets/subdivision_images/4";
String eight = "assets/subdivision_images/8";