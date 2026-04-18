/// Randevu `StoreServicePlanRequest` / Fitiz schedule — `period` alanı.
enum ServicePeriodType {
  weekly('WEEKLY'),
  oneTime('ONE_TIME');

  const ServicePeriodType(this.apiValue);
  final String apiValue;
}
