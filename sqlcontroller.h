#ifndef SQLCONTROLLER_H
#define SQLCONTROLLER_H

#include <QObject>
#include <QFileSystemWatcher>

#include <QSqlError>
#include <QSqlQuery>
#include <QSqlRecord>
#include <QSqlDatabase>
#include <QDir>
#include <QStandardPaths>

class SQLController : public QObject
{
    Q_OBJECT


private:
    QFileSystemWatcher* m_fileSystemWatcher = nullptr;


    void createMusicsTable();
    void createPlaylistsTable();
    void createMusicsInPlaylistTable();

private slots:

    QStringList getAllMusicInDirectory(const QString &path);
    void checkDirectoryChangesInDatabase(const QString &path);
    void addFolderToWathcer(const QString &source);
    void directoryChanged(const QString &path);

public:

    enum DefaultPlaylists {
        RecentlyAdded = 1,
        RecentlyPlayed,
        MostPlayed,
        Favourites
    };
    Q_ENUM(DefaultPlaylists)

    static QSqlDatabase m_databse;

    explicit SQLController(QObject *parent = nullptr);
    ~SQLController() = default;

    Q_INVOKABLE int addNewFolder(const QString &sourcePath);
    Q_INVOKABLE int addNewPlaylist(const QString &name);

    Q_INVOKABLE int addNewMusic(const QString &path, const QString &title,const QString &artist);
    Q_INVOKABLE int addMusicToPlaylist(const int &musicID, const int &folderID);

    Q_INVOKABLE void updatePlaylistName(const int &id, const QString &newName);

    Q_INVOKABLE void deleteFolder(const int &id);
    Q_INVOKABLE void deletePlaylist(const int &id);

    Q_INVOKABLE void deleteMusic(const int &id);

    Q_INVOKABLE void insertAllMusicsInFolder(const int &folderId, const QString &folderPath);

    Q_INVOKABLE QVariant getAllMusicsInPlaylist(const int &playlistID);

    Q_INVOKABLE QVariant getAllMusicsInFavourites();
    Q_INVOKABLE QVariant getAllMusicsInRecentlyAdded();
    Q_INVOKABLE QVariant getAllMusicsInRecentlyPlayed();
    Q_INVOKABLE QVariant getAllMusicsInMostPlayed();

    Q_INVOKABLE QVariant getMusicInfoByID(const int &musicID);
    Q_INVOKABLE QVariant getFolderInfoByID(const int &folderID);
    Q_INVOKABLE QVariant getPlaylistInfoByID(const int &playlistID);


    Q_INVOKABLE QVariant getAllPlaylists();
    Q_INVOKABLE QVariant getAllFolders();

    Q_INVOKABLE QList<QVariantMap> getFolderInfoByPath(const QString &path);

signals:

    void newMusicAdded(const int &playlistID, const int &musicID);
    void musicDeleted(const int &musicID);

    void musicDeletedFromPlaylist(const int &playlistID, const int &musicID);

    void playlistUpdated(const int &id);

    void playlistDeleted(const int &id);
    void folderDeleted(const int &id);

    void newFolderAdded(const int &id);
    void newPlaylistAdded(const int &id);
};

#endif // SQLCONTROLLER_H
