
from astropy.coordinates import SkyCoord, AltAz, EarthLocation
from astropy.time import Time

if __name__ == "__main__":
    c = SkyCoord(ra=90.0, dec=20.0, frame="icrs", unit="deg")
    loc = EarthLocation.of_site("palomar")
    t = Time(58290.0, format="mjd")
    out = c.transform_to(AltAz(obstime=t, location=loc))
                            
    print("Input: ", c)
    print("jd: ", t.jd)
    print("Location: ", loc, loc.lon.deg, loc.lat.deg)
    print("Output: ", out)

    print("-"*10)

    t = Time('2006-01-15T21:24:37.5', scale='utc', location=('120d', '45d'))
    print("time JD: ", t.jd )
    print("time unix: ", t.unix )
    print("time: ", t.sidereal_time('mean').deg  )