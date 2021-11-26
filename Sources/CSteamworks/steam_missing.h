// Stuff that's missing from the API headers that it's easier to patch
// in here rather than the Swift side.

// If we find more than one of the same kind of thing and its plausible
// to generate it then stop and make it generated.


// Enumify 'game server flags' from isteammatchmaking.h.
// Despite the name appears to be an enum rather than a bitset?

enum EFavoriteFlags
{
  k_EFavoriteFlagsNone = k_unFavoriteFlagNone,
  k_EFavoriteFlagFavorite = k_unFavoriteFlagFavorite,
  k_EFavoriteFlagHistory = k_unFavoriteFlagHistory
};

static inline bool CSteamAPI_ISteamMatchmaking_GetFavoriteGame( ISteamMatchmaking* self, int iGame, AppId_t * pnAppID, uint32 * pnIP, uint16 * pnConnPort, uint16 * pnQueryPort, EFavoriteFlags * punFlags, uint32 * pRTime32LastPlayedOnServer ) {
  SteamAPI_ISteamMatchmaking_GetFavoriteGame(self, iGame, pnAppID, pnIP, pnConnPort, pnQueryPort, reinterpret_cast<uint32 *>(punFlags), pRTime32LastPlayedOnServer);
}

static inline int CSteamAPI_ISteamMatchmaking_AddFavoriteGame( ISteamMatchmaking* self, AppId_t nAppID, uint32 nIP, uint16 nConnPort, uint16 nQueryPort, EFavoriteFlags unFlags, uint32 rTime32LastPlayedOnServer ) {
  return SteamAPI_ISteamMatchmaking_AddFavoriteGame(self, nAppID, nIP, nConnPort, nQueryPort, unFlags, rTime32LastPlayedOnServer);
}

static inline bool CSteamAPI_ISteamMatchmaking_RemoveFavoriteGame( ISteamMatchmaking* self, AppId_t nAppID, uint32 nIP, uint16 nConnPort, uint16 nQueryPort, EFavoriteFlags unFlags ) {
  return CSteamAPI_ISteamMatchmaking_RemoveFavoriteGame(self, nAppID, nIP, nConnPort, nQueryPort, unFlags);
}