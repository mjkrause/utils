#!/usr/bin/env python3


def validate_iso8601(ts):
    """Check validity of a timestamp in ISO 8601 format."""
    digits = [0, 1, 2, 3, 5, 6, 8, 9, 11, 12, 14, 15, 17, 18, 20, 21, 22]
    try:
        assert len(ts) == 24
        assert all([ts[i].isdigit() for i in digits])
        assert int(ts[5:7]) <= 12
        assert int(ts[8:10]) < 32
        assert int(ts[11:13]) < 24
        assert all([i < 60 for i in [int(ts[14: 16]), int(ts[17: 19])]])
        assert all([ts[i] == '-' for i in [4, 7]])
        assert all([ts[i] == ':' for i in [13, 16]])
        assert ts[19] == '.'
        assert ts[10].lower() == 't'
        assert ts[23].lower() == 'z'
        return True
    except AssertionError:
        pass
    return False
