class TrackingStep {
  const TrackingStep({
    required this.title,
    required this.date,
    required this.description,
  });

  final String title;
  final String date;
  final String description;
}

class TrackingData {
  static const List<TrackingStep> mockSteps = [
    TrackingStep(
      title: 'Order Accepted',
      date: 'Thu, 13 December',
      description: 'Lorem ipsum dolor sit amet, consetetur '
          'sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut',
    ),
    TrackingStep(
      title: 'Order Placed',
      date: 'Fri, 14 December',
      description: 'Lorem ipsum dolor sit amet, consetetur '
          'sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut',
    ),
    TrackingStep(
      title: 'Order Shipped',
      date: 'Fri, 14 December',
      description: 'Lorem ipsum dolor sit amet, consetetur '
          'sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut',
    ),
  ];
}
