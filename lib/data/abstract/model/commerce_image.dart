class CommerceImage {
  final String address;

  final String altText;
  final bool isLocal;

  CommerceImage(this.address, this.altText, {this.isLocal = false});

  CommerceImage.remote(this.address)
      : isLocal = false,
        altText = '';

  CommerceImage.placeHolder()
      : this('assets/placeholder.png', 'no image', isLocal: true);
}
