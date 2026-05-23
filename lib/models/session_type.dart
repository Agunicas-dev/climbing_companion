enum SessionEnvironment { indoor, outdoor }

enum SessionDiscipline { boulder, lead }

class SessionType {
  final SessionEnvironment environment;
  final SessionDiscipline discipline;

  const SessionType({required this.environment, required this.discipline});

  static const defaultType = SessionType(
    environment: SessionEnvironment.indoor,
    discipline: SessionDiscipline.boulder,
  );
}

extension SessionEnvironmentLabel on SessionEnvironment {
  String get storageValue => switch (this) {
    SessionEnvironment.indoor => 'indoor',
    SessionEnvironment.outdoor => 'outdoor',
  };

  String get label => switch (this) {
    SessionEnvironment.indoor => 'Indoor',
    SessionEnvironment.outdoor => 'Outdoor',
  };
}

extension SessionDisciplineLabel on SessionDiscipline {
  String get storageValue => switch (this) {
    SessionDiscipline.boulder => 'boulder',
    SessionDiscipline.lead => 'lead',
  };

  String get label => switch (this) {
    SessionDiscipline.boulder => 'Boulder',
    SessionDiscipline.lead => 'Lead',
  };
}

String sessionEnvironmentLabel(String value) {
  return switch (value) {
    'outdoor' => SessionEnvironment.outdoor.label,
    _ => SessionEnvironment.indoor.label,
  };
}

String sessionDisciplineLabel(String value) {
  return switch (value) {
    'lead' => SessionDiscipline.lead.label,
    _ => SessionDiscipline.boulder.label,
  };
}
