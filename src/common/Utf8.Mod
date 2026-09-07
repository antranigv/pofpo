MODULE Utf8;

TYPE
  Char* = LONGINT;

PROCEDURE EncodeLen*(u: Char): INTEGER;
BEGIN
  IF u < 80H THEN RETURN 1
  ELSIF u < 800H THEN RETURN 2
  ELSIF u < 10000H THEN RETURN 3
  ELSE RETURN 4
  END
END EncodeLen;

PROCEDURE Chr*(u: Char; VAR s: ARRAY OF CHAR; VAR n: INTEGER);
BEGIN
  IF (u < 0) OR (u > 10FFFFH) OR ((u >= 0D800H) & (u < 0E000H)) THEN u := 0FFFDH END;
  IF u < 80H THEN
    s[0] := CHR(u); n := 1
  ELSIF u < 800H THEN
    s[0] := CHR(0C0H + u DIV 40H);
    s[1] := CHR(080H + u MOD 40H); n := 2
  ELSIF u < 10000H THEN
    s[0] := CHR(0E0H + u DIV 1000H);
    s[1] := CHR(080H + (u DIV 40H) MOD 40H);
    s[2] := CHR(080H + u MOD 40H); n := 3
  ELSE
    s[0] := CHR(0F0H + u DIV 40000H);
    s[1] := CHR(080H + (u DIV 1000H) MOD 40H);
    s[2] := CHR(080H + (u DIV 40H) MOD 40H);
    s[3] := CHR(080H + u MOD 40H); n := 4
  END
END Chr;

PROCEDURE Ord*(VAR s(*-*): ARRAY OF CHAR; pos: INTEGER; VAR u: Char; VAR size: INTEGER): BOOLEAN;
VAR c, c1, c2, c3: INTEGER;
BEGIN
  c := ORD(s[pos]);
  IF c < 80H THEN
    u := c; size := 1; RETURN TRUE
  ELSIF (c >= 0C2H) & (c < 0E0H) THEN
    c1 := ORD(s[pos+1]);
    IF (c1 >= 080H) & (c1 < 0C0H) THEN
      u := (c - 0C0H) * 40H + c1 - 080H; size := 2; RETURN TRUE
    END
  ELSIF (c >= 0E0H) & (c < 0F0H) THEN
    c1 := ORD(s[pos+1]); c2 := ORD(s[pos+2]);
    IF (c1 >= 080H) & (c1 < 0C0H) & (c2 >= 080H) & (c2 < 0C0H)
        & ((c # 0E0H) OR (c1 >= 0A0H)) & ((c # 0EDH) OR (c1 < 0A0H)) THEN
      u := (c - 0E0H) * 1000H + (c1 - 080H) * 40H + c2 - 080H;
      size := 3; RETURN TRUE
    END
  ELSIF (c >= 0F0H) & (c <= 0F4H) THEN
    c1 := ORD(s[pos+1]); c2 := ORD(s[pos+2]); c3 := ORD(s[pos+3]);
    IF (c1 >= 080H) & (c1 < 0C0H) & (c2 >= 080H) & (c2 < 0C0H)
        & (c3 >= 080H) & (c3 < 0C0H)
        & ((c # 0F0H) OR (c1 >= 090H)) & ((c # 0F4H) OR (c1 < 090H)) THEN
      u := (c - 0F0H) * 40000H + (c1 - 080H) * 1000H
        + (c2 - 080H) * 40H + c3 - 080H;
      size := 4; RETURN TRUE
    END
  END;
  u := -1; size := 1; RETURN FALSE
END Ord;

PROCEDURE Next*(VAR s(*-*): ARRAY OF CHAR; VAR pos: INTEGER; VAR u: Char): BOOLEAN;
VAR size: INTEGER;
BEGIN
  IF Ord(s, pos, u, size) THEN INC(pos, size); RETURN TRUE
  ELSE INC(pos); RETURN FALSE
  END
END Next;

END Utf8.
