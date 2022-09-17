#include "sqlcontroller.h"

QSqlDatabase SQLController::m_databse;

SQLController::SQLController(QObject *parent)
    : QObject{parent}
{
    m_fileSystemWatcher = new QFileSystemWatcher(this);

    connect(m_fileSystemWatcher, &QFileSystemWatcher::directoryChanged, this, &SQLController::directoryChanged);

    if(!m_databse.isValid())
    {
        m_databse = QSqlDatabase::addDatabase("QSQLITE");

        QDir path = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
        if(!path.exists())
            path.mkpath(path.path());

        qDebug() << path.path();

        m_databse.setDatabaseName(path.path() + "/CutePlayer.sqlite");
    }

    if (!m_databse.isOpen() && !m_databse.open())
    {
        qDebug() << "Error: connection with database failed"<< m_databse.lastError();
    }

    this->createMusicsTable();
    this->createPlaylistsTable();
    this->createMusicsInPlaylistTable();
}

int SQLController::addNewFolder(const QString &sourcePath)
{
    if(this->getFolderInfoByPath(sourcePath).isEmpty() == false)
    {
        qDebug() << "Already added in database";
        return -2;
    }
    QDir checkDir{sourcePath};
    if( checkDir.exists(sourcePath) != true)
    {
        qDebug() << "Folder not exists";
        return -3;
    }

    QString queryStr("INSERT INTO 'Playlists'(name,is_folder,path)"
                     "VALUES('%1',%2,'%3'"
                     ");"
                     );

    QString name = sourcePath.split(QDir::separator()).last();
    queryStr =  queryStr.arg(name)
            .arg(1)
            .arg(sourcePath);

    QSqlQuery sqlQuery(this->m_databse);
    sqlQuery.prepare(queryStr);

    if(sqlQuery.exec() != true)
    {
        QSqlError error = sqlQuery.lastError();
        qDebug()<< sqlQuery.executedQuery() << error.text();
        return -1;
    }
    else {
        int id = sqlQuery.lastInsertId().toInt();
        this->addFolderToWathcer(sourcePath);
        this->insertAllMusicsInFolder(id,sourcePath);
        return id;
    }
}

int SQLController::addNewPlaylist(const QString &name)
{
    QString queryStr("INSERT INTO Playlists(name) "
                     "VALUES('%1');"
                     );

    queryStr = queryStr.arg(name);

    QSqlQuery sqlQuery(this->m_databse);
    sqlQuery.prepare(queryStr);

    if(sqlQuery.exec() != true)
    {
        QSqlError error = sqlQuery.lastError();
        qDebug()<< sqlQuery.executedQuery() << error.text();
        return -1;
    }
    else {
        int id = sqlQuery.lastInsertId().toInt();
        emit newFolderAdded(id);
        return id;
    }
}

int SQLController::addNewMusic(const QString &path, const QString &title, const QString &artist)
{
    QString queryStr("INSERT INTO 'Musics'(title,artist,path) "
                     "VALUES('%1','%2','%3');"
                     );

    queryStr = queryStr.arg(title)
            .arg(artist)
            .arg(path);

    QSqlQuery sqlQuery(this->m_databse);
    sqlQuery.prepare(queryStr);

    if(sqlQuery.exec() != true)
    {
        QSqlError error = sqlQuery.lastError();
        qDebug()<< sqlQuery.executedQuery() << error.text();
        return -1;
    }
    else {
        int id = sqlQuery.lastInsertId().toInt();
        return id;
    }
}

int SQLController::addMusicToPlaylist(const int &musicID, const int &playlistID)
{
    QString queryStr("INSERT INTO 'MusicsInPlaylists'(music_id,playlist_id) "
                     "VALUES( %1 , %2 );"
                     );

    queryStr = queryStr.arg(musicID)
            .arg(playlistID);

    QSqlQuery sqlQuery(this->m_databse);
    sqlQuery.prepare(queryStr);

    if(sqlQuery.exec() != true)
    {
        QSqlError error = sqlQuery.lastError();
        qDebug()<< sqlQuery.executedQuery() << error.text();
        return -1;
    }
    else {
        int id = sqlQuery.lastInsertId().toInt();
        emit newMusicAdded(playlistID,musicID);
        return id;
    }
}

void SQLController::updatePlaylistName(const int &id, const QString &newName)
{
    QString queryStr("UPDATE 'Playlists' SET name='%1 WHERE id=%2';");

    queryStr = queryStr.arg(newName)
            .arg(id);

    QSqlQuery sqlQuery(this->m_databse);
    sqlQuery.prepare(queryStr);

    if(sqlQuery.exec() != true)
    {
        QSqlError error = sqlQuery.lastError();
        qDebug()<< sqlQuery.executedQuery() << error.text();
    }
    else {
        emit this->playlistUpdated(id);
    }
}

void SQLController::deleteFolder(const int &id)
{
    QString queryStr("DELETE FROM 'Playlists' WHERE id=%1';");

    queryStr = queryStr.arg(id);

    QSqlQuery sqlQuery(this->m_databse);
    sqlQuery.prepare(queryStr);

    if(sqlQuery.exec() != true)
    {
        QSqlError error = sqlQuery.lastError();
        qDebug()<< sqlQuery.executedQuery() << error.text();
    }
    else {
        emit this->playlistDeleted(id);
    }
}

void SQLController::deletePlaylist(const int &id)
{
    QString queryStr("DELETE FROM 'Playlists' WHERE id=%1';");

    queryStr = queryStr.arg(id);

    QSqlQuery sqlQuery(this->m_databse);
    sqlQuery.prepare(queryStr);

    if(sqlQuery.exec() != true)
    {
        QSqlError error = sqlQuery.lastError();
        qDebug()<< sqlQuery.executedQuery() << error.text();
    }
    else {
        emit this->folderDeleted(id);
    }
}

void SQLController::deleteMusic(const int &id)
{
    QString queryStr("DELETE FROM 'Musics' WHERE id=%1';");

    queryStr = queryStr.arg(id);

    QSqlQuery sqlQuery(this->m_databse);
    sqlQuery.prepare(queryStr);

    if(sqlQuery.exec() != true)
    {
        QSqlError error = sqlQuery.lastError();
        qDebug()<< sqlQuery.executedQuery() << error.text();
    }
    else {
        emit this->musicDeleted(id);
    }
}

void SQLController::insertAllMusicsInFolder(const int &folderId, const QString &folderPath)
{
    const QStringList musics = this->getAllMusicInDirectory(folderPath);
    for(const QString &musicPath: musics)
    {
        int id = this->addNewMusic(musicPath,"","");
        if (id != -1)
        {
            this->addMusicToPlaylist(id,folderId);
        }
    }
    emit newFolderAdded(folderId);
}

QVariant SQLController::getAllMusicsInPlaylist(const int &playlistID)
{
    QString queryStr("SELECT Musics.* FROM Musics JOIN MusicsInPlaylists ON MusicsInPlaylists.music_id=Musics.id AND MusicsInPlaylists.playlist_id = %1");

    queryStr = queryStr.arg(playlistID);

    QSqlQuery sqlQuery(this->m_databse);
    sqlQuery.prepare(queryStr);

    QList <QVariantMap> dataList;
    if(sqlQuery.exec() == true)
    {
        while (sqlQuery.next())
        {
            QSqlRecord record = sqlQuery.record();
            QVariantMap data;
            for(int i= 0; i< record.count();i++)
            {
                data[record.fieldName(i)] = record.value(i);
            }
            dataList.append(data);
        }
    }
    return QVariant::fromValue(dataList);
}

QVariant SQLController::getAllMusicsInFavourites()
{
    QString queryStr("SELECT * FROM Musics WHERE is_favourite=1");

    QSqlQuery sqlQuery(this->m_databse);
    sqlQuery.prepare(queryStr);

    QList <QVariantMap> dataList;
    if(sqlQuery.exec() == true)
    {
        while (sqlQuery.next())
        {
            QSqlRecord record = sqlQuery.record();
            QVariantMap data;
            for(int i= 0; i< record.count();i++)
            {
                data[record.fieldName(i)] = record.value(i);
            }
            dataList.append(data);
        }
    }
    return QVariant::fromValue(dataList);
}

QVariant SQLController::getAllMusicsInRecentlyAdded()
{
    QString queryStr("SELECT * FROM Musics ORDER BY added_date DESC,id DESC LIMIT 100");

    QSqlQuery sqlQuery(this->m_databse);
    sqlQuery.prepare(queryStr);

    QList <QVariantMap> dataList;
    if(sqlQuery.exec() == true)
    {
        while (sqlQuery.next())
        {
            QSqlRecord record = sqlQuery.record();
            QVariantMap data;
            for(int i= 0; i< record.count();i++)
            {
                data[record.fieldName(i)] = record.value(i);
            }
            dataList.append(data);
        }
    }
    return QVariant::fromValue(dataList);
}

QVariant SQLController::getAllMusicsInRecentlyPlayed()
{
    QString queryStr("SELECT * FROM Musics WHERE last_played_date!='' ORDER BY last_played_date DESC,id DESC LIMIT 100");


    QSqlQuery sqlQuery(this->m_databse);
    sqlQuery.prepare(queryStr);

    QList <QVariantMap> dataList;
    if(sqlQuery.exec() == true)
    {
        while (sqlQuery.next())
        {
            QSqlRecord record = sqlQuery.record();
            QVariantMap data;
            for(int i= 0; i< record.count();i++)
            {
                data[record.fieldName(i)] = record.value(i);
            }
            dataList.append(data);
        }
    }
    return QVariant::fromValue(dataList);
}

QVariant SQLController::getAllMusicsInMostPlayed()
{
    QString queryStr("SELECT * FROM Musics WHERE number_of_played!=0 ORDER BY number_of_played DESC,added_date DESC LIMIT 100");

    QSqlQuery sqlQuery(this->m_databse);
    sqlQuery.prepare(queryStr);

    QList <QVariantMap> dataList;
    if(sqlQuery.exec() == true)
    {
        while (sqlQuery.next())
        {
            QSqlRecord record = sqlQuery.record();
            QVariantMap data;
            for(int i= 0; i< record.count();i++)
            {
                data[record.fieldName(i)] = record.value(i);
            }
            dataList.append(data);
        }
    }
    return QVariant::fromValue(dataList);
}

QVariant SQLController::getMusicInfoByID(const int &musicID)
{
    QString queryStr("SELECT * FROM Musics WHERE id=%1");

    queryStr = queryStr.arg(musicID);

    QSqlQuery sqlQuery(this->m_databse);
    sqlQuery.prepare(queryStr);

    QList <QVariantMap> dataList;
    if(sqlQuery.exec() == true)
    {
        while (sqlQuery.next())
        {
            QSqlRecord record = sqlQuery.record();
            QVariantMap data;
            for(int i= 0; i< record.count();i++)
            {
                data[record.fieldName(i)] = record.value(i);
            }
            dataList.append(data);
        }
    }
    return QVariant::fromValue(dataList);
}

QVariant SQLController::getFolderInfoByID(const int &folderID)
{
    return this->getPlaylistInfoByID(folderID);
}

QVariant SQLController::getPlaylistInfoByID(const int &playlistID)
{
    QString queryStr("SELECT Playlists.*, COUNT(Playlists.id) AS number_of_tracks FROM Playlists"
                     " JOIN MusicsInPlaylists ON MusicsInPlaylists.playlist_id = Playlists.id AND Playlists.id = %1"
                     " GROUP BY Playlists.id"
                     );

    queryStr = queryStr.arg(playlistID);

    QSqlQuery sqlQuery(this->m_databse);
    sqlQuery.prepare(queryStr);

    QList <QVariantMap> dataList;
    if(sqlQuery.exec() == true)
    {
        while (sqlQuery.next())
        {
            QSqlRecord record = sqlQuery.record();
            QVariantMap data;
            for(int i= 0; i< record.count();i++)
            {
                data[record.fieldName(i)] = record.value(i);
            }
            dataList.append(data);
        }
    }
    return QVariant::fromValue(dataList);
}

QVariant SQLController::getAllPlaylists()
{
    QString queryStr("SELECT P.*, "
                     "ifnull((SELECT COUNT(*) FROM Playlists JOIN MusicsInPlaylists ON playlist_id=P.id GROUP BY Playlists.id),0) AS number_of_tracks "
                     "FROM Playlists as P WHERE P.is_folder=0"
                     );

    QSqlQuery sqlQuery(this->m_databse);
    sqlQuery.prepare(queryStr);

    QList <QVariantMap> dataList;

    if(sqlQuery.exec() == true)
    {
        while (sqlQuery.next())
        {
            QSqlRecord record = sqlQuery.record();
            QVariantMap data;
            for(int i= 0; i< record.count();i++)
            {
                data[record.fieldName(i)] = record.value(i);
            }
            dataList.append(data);
        }
    }

    return QVariant::fromValue(dataList);
}

QVariant SQLController::getAllFolders()
{
    QString queryStr("SELECT P.*, "
                     "ifnull((SELECT COUNT(*) FROM Playlists JOIN MusicsInPlaylists ON playlist_id=P.id GROUP BY Playlists.id),0) AS number_of_tracks "
                     "FROM Playlists as P WHERE P.is_folder=1"
                     );

    QSqlQuery sqlQuery(this->m_databse);
    sqlQuery.prepare(queryStr);

    QList <QVariantMap> dataList;
    if(sqlQuery.exec() == true)
    {
        while (sqlQuery.next())
        {
            QSqlRecord record = sqlQuery.record();
            QVariantMap data;
            for(int i= 0; i< record.count();i++)
            {
                data[record.fieldName(i)] = record.value(i);
            }
            dataList.append(data);
        }
    }
    return QVariant::fromValue(dataList);
}

QList <QVariantMap> SQLController::getFolderInfoByPath(const QString &path)
{
    QString queryStr("SELECT * FROM 'Playlists' WHERE path='%1'");

    queryStr = queryStr.arg(path);

    QSqlQuery sqlQuery(this->m_databse);
    sqlQuery.prepare(queryStr);

    QList <QVariantMap> dataList;
    if(sqlQuery.exec() == true)
    {
        while (sqlQuery.next())
        {
            QSqlRecord record = sqlQuery.record();
            QVariantMap data;
            for(int i= 0; i< record.count();i++)
            {
                data[record.fieldName(i)] = record.value(i);
            }
            dataList.append(data);
        }
    }
    return dataList;
}

void SQLController::createMusicsTable()
{
    QSqlQuery sqlQuery(this->m_databse);
    QString queryStr("CREATE TABLE IF NOT EXISTS 'Musics' ("
                     "'id'	INTEGER NOT NULL UNIQUE,"
                     "'title'	TEXT,"
                     "'artist'	TEXT,"
                     "'path'	TEXT NOT NULL UNIQUE,"
                     "'number_of_played'	INTEGER NOT NULL DEFAULT 0,"
                     "'is_favourite'	INTEGER NOT NULL DEFAULT 0,"
                     "'added_date'	TEXT NOT NULL DEFAULT current_timestamp,"
                     "'last_played_date'	TEXT    DEFAULT '',"
                     "PRIMARY KEY('id' AUTOINCREMENT)"
                     ");"
                     );

    sqlQuery.prepare(queryStr);
    if(sqlQuery.exec() != true)
    {
        QSqlError error = sqlQuery.lastError();
        qDebug() << "createMusicsTable" << error.text();
    }
}

void SQLController::createPlaylistsTable()
{
    QSqlQuery sqlQuery(this->m_databse);
    QString queryStr("CREATE TABLE IF NOT EXISTS 'Playlists' ("
                     "'id'	INTEGER NOT NULL UNIQUE,"
                     "'name'	TEXT NOT NULL,"
                     "'is_folder'	INTEGER NOT NULL DEFAULT 0,"
                     "'path'	INTEGER DEFAULT '',"
                     "PRIMARY KEY('id' AUTOINCREMENT)"
                     ");"
                     );

    sqlQuery.prepare(queryStr);
    if(sqlQuery.exec() != true)
    {
        QSqlError error = sqlQuery.lastError();
        qDebug() << "createPlaylistsTable" << error.text();
    }
}

void SQLController::createMusicsInPlaylistTable()
{
    QSqlQuery sqlQuery(this->m_databse);
    QString queryStr("CREATE TABLE IF NOT EXISTS 'MusicsInPlaylists' ("
                     "    'id'	INTEGER NOT NULL UNIQUE,"
                     "    'music_id'	INTEGER NOT NULL,"
                     "    'playlist_id'	INTEGER NOT NULL,"
                     "    FOREIGN KEY('music_id') REFERENCES 'Musics'('id') ON DELETE CASCADE,"
                     "    FOREIGN KEY('playlist_id') REFERENCES 'Playlists'('id') ON DELETE CASCADE,"
                     "    PRIMARY KEY('id' AUTOINCREMENT)"
                     ");"
                     );

    sqlQuery.prepare(queryStr);
    if(sqlQuery.exec() != true)
    {
        QSqlError error = sqlQuery.lastError();
        qDebug() << "createMusicsInPlaylistTable"  << error.text();
    }
}

QStringList SQLController::getAllMusicInDirectory(const QString &path)
{
    QDir source{path};

    QStringList audioFormats{"*.mp3","*.wav","*.aiff","*.aac","*.ogg","*.wma","*.flac"};
    QStringList const files = source.entryList(audioFormats, QDir::Files);

    QStringList fullPathList{};

    for(const QString &file: files)
        fullPathList << source.path()+QDir::separator()+file;

    return fullPathList;
}

void SQLController::checkDirectoryChangesInDatabase(const QString &path)
{

}

void SQLController::addFolderToWathcer(const QString &source)
{

}

void SQLController::directoryChanged(const QString &path)
{

}


