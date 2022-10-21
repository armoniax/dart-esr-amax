
/// Emitted when a network error occurs, can safely be ignored. */
// class SocketError extends Error {
//   final String code = 'E_NETWORK';
//   SocketError(Event event);
// }



/// Emitted when a message fails to parse or read, non-recoverable. */
// class MessageError extends Error {
//     code = 'E_MESSAGE'
//     constructor(readonly reason = string, readonly underlyingError?: Error) {
//         super(reason)
//     }
// }