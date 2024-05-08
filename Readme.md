# OSM-GREP

Порой нужно вытащить из OSM какие-то данные, к примеру, больницы и прочие медицинские учереждения по всему миру, но как это сделать? Особенно учитывая хаос тегирования?

Создаем текстовый файлик вида:

```
amenity=clinic
amenity=clinic;hospital
amenity=community_health_center
amenity=dentist
amenity=doctor
amenity=doctors
amenity=doctors;dentist
```

И запускаем утиль как-то так:

```
osm-grep.exe Planet.PBF tagslist.txt tags-output.gz
```

Параметры тут такие:

* Первый параметр - имя PBF-файла, который мы грепаем
* Второй параметр - имя текстового файла с тегами, которые мы нашли
* Третий - имя файла, куда будет сохранен результат. Если указать в имени `.gz`, то файлик будет сжатым.

На выходе получаем что-то вроде:

```
lat/lon 4533348620/-27973883000: addr:housenumber=1;; addr:street=Gert Lubbe Street;; amenity=clinic;; name=Ganspan Clinic;; wikidata=Q58020961;;
lat/lon 4533949614/-28777899600: addr:city=Kimberley, Northern Cape;; addr:housenumber=23;; addr:street=Dutch Reform Street;; amenity=clinic;; healthcare=clinic;; name=Greenpoint Clinic;; wikidata=Q58020982;;
lat/lon 4533980461/-28128081700: addr:city=Warrenton;; addr:postcode=8530;; addr:street=Main Road;; amenity=clinic;; healthcare=clinic;; name=Pholong Clinic;;
lat/lon 4551888991/-29062442700: addr:city=Greytown;; addr:housenumber=R74;; addr:postcode=3250;; addr:street=Stanger Road;; amenity=clinic;;healthcare=clinic;; healthcare:speciality=rehabilitation;;
lat/lon 4573728080/-33893706500: amenity=pharmacy;; name=Alpha Pharm Broadway Pharmacy;; opening_hours=Mo-Fr 08:00-19:00, Sa 09:00-13:00, Su 10:00-12:00;;
```

Далее можно воспользоваться тулами, чтобы найти еще тегов (к примеру, `healthcare=clinic` в изначальном запросе не встречается), или использовать это уже для конечных целей.

## Зависимости

```
OSM-binary-master.zip
protobuf-cpp-3.4.1.tar.gz
zlib-1.3.1.tar.gz
```

# TODO:

Добавить POI, которые были бы наиболее важными, если человек оказался в незнакомой стране:
* Посольства
* Источники питьевой воды/еды
* Церкви и центры помощи бездомным
