## 0.1.0

- Initial version.

## 0.2.0

- Added error handling mechanism in the parsing methods, ensuring that parsing of ill-formed text returns empty BpmfSyllable with unchanged startIdx. All the methods fromPinyin, fromAsciiPinyin and fromBopomofo will return
empty string if a piece of bad text has been fed in. All in all, it will no longer throw an exception at your face. 
