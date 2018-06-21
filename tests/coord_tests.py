
from astropy.coordinates import SkyCoord, AltAz, EarthLocation
from astropy.time import Time

if __name__ == "__main__":
    c = SkyCoord(ra=10.0, dec=20.0, frame="icrs", unit="deg")
    print(EarthLocation.of_site("palomar"))
    out = c.transform_to(AltAz(obstime=Time(58290.0, format="mjd"),
                               location=EarthLocation.of_site("palomar")))
    print(out)