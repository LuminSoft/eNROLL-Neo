import 'package:enroll_neo_plugin/constants/enroll_init_model.dart';
import 'package:enroll_neo_plugin/enroll_neo_plugin.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('questionnaire mode serializes public contract fields', () {
    final model = EnrollInitModel(
      tenantId: 'tenant',
      tenantSecret: 'secret',
      applicantId: 'applicant',
      questionnaireId: 'questionnaire',
      enrollMode: EnrollMode.questionnaire.name,
      onGettingRequestId: (_) {},
    );

    expect(EnrollMode.questionnaire.name, 'questionnaire');
    expect(model.toJson()['enrollMode'], 'questionnaire');
    expect(model.toJson()['applicationId'], 'applicant');
    expect(model.toJson()['questionnaireId'], 'questionnaire');
  });
}
