p = Phonogram.find(2)
p.source_sound.attach(
  io: File.open('some_rec.mp3'),
  filename: 'some_rec.mp3',
  content_type: 'audio/mpeg',
)
