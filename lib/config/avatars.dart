const kAvatarList = [
  (id: 'avatar1', path: 'assets/avatars/elon.jpg',       name: 'Elon Musk'),
  (id: 'avatar2', path: 'assets/avatars/bezos.jpg',      name: 'Jeff Bezos'),
  (id: 'avatar3', path: 'assets/avatars/gates.jpg',      name: 'Bill Gates'),
  (id: 'avatar4', path: 'assets/avatars/buffett.jpg',    name: 'Warren Buffett'),
  (id: 'avatar5', path: 'assets/avatars/zuckerberg.jpg', name: 'Mark Zuckerberg'),
  (id: 'avatar6', path: 'assets/avatars/ellison.jpg',    name: 'Larry Ellison'),
];

String avatarPath(String id) =>
    kAvatarList.firstWhere((a) => a.id == id, orElse: () => kAvatarList.first).path;

String avatarName(String id) =>
    kAvatarList.firstWhere((a) => a.id == id, orElse: () => kAvatarList.first).name;
