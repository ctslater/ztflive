
from astropy.coordinates import SkyCoord, AltAz, EarthLocation
from astropy.time import Time

if __name__ == "__main__":
    c = SkyCoord(ra=10.0, dec=20.0, frame="icrs", unit="deg")
    out = c.transform_to(AltAz(obstime=Time(58290.0, format="mjd"),
                               location=EarthLocation.of_site("palomar")))
    print(out)

    t = Time('2006-01-15 21:24:37.5', scale='utc', location=('120d', '45d'))
    print("time: ", t.sidereal_time('mean').deg  )