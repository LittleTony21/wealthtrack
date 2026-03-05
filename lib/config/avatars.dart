const kAvatarList = [
  (id: 'avatar1', path: 'assets/avatars/Elonmusk.jpg',        name: 'Elon Musk'),
  (id: 'avatar2', path: 'assets/avatars/jeff bezos.webp',     name: 'Jeff Bezos'),
  (id: 'avatar3', path: 'assets/avatars/warrenbuffet.jpg',    name: 'Warren Buffett'),
  (id: 'avatar4', path: 'assets/avatars/Markzarkebeger.jpg',  name: 'Mark Zuckerberg'),
  (id: 'avatar5', path: 'assets/avatars/jensonwong.jpg',      name: 'Jensen Huang'),
  (id: 'avatar6', path: 'assets/avatars/Larry Ellison.jpg',   name: 'Larry Ellison'),
];

String avatarPath(String id) =>
    kAvatarList.firstWhere((a) => a.id == id, orElse: () => kAvatarList.first).path;

String avatarName(String id) =>
    kAvatarList.firstWhere((a) => a.id == id, orElse: () => kAvatarList.first).name;
