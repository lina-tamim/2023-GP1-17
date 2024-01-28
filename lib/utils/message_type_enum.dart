enum MessageTypeEnum {
  text('text', 'Text'),
  image('image', 'Image');

  const MessageTypeEnum(this.json, this.title);
  final String json;
  final String title;
}

class MessageTypeEnumConvertor {
  static MessageTypeEnum toEnum(String type) {
    if (type == 'image') {
      return MessageTypeEnum.image;
    }
    return MessageTypeEnum.text;
  }
}
