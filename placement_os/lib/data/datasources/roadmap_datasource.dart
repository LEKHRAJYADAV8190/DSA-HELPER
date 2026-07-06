/// Future-ready roadmap loading. Only Striver A2Z is registered today.
abstract class RoadmapDataSource {
  String get id;
  String get name;
  String get assetPath;
}

class StriverA2ZRoadmap implements RoadmapDataSource {
  const StriverA2ZRoadmap();

  @override
  String get id => 'striver_a2z';

  @override
  String get name => 'Striver A2Z DSA Sheet';

  @override
  String get assetPath => 'assets/data/striver_a2z.json';
}

abstract final class RoadmapRegistry {
  static const active = StriverA2ZRoadmap();
  static const all = <RoadmapDataSource>[StriverA2ZRoadmap()];
}
