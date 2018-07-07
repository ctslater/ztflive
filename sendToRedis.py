from __future__ import print_function
import argparse
import sys
import os
from datetime import datetime
from lsst.alert.stream import alertConsumer

import redis


def process_alert(alert, redis_conn, expire=False, date=False):
    candidate = alert['candidate']
    field = candidate['field']
    jd = candidate['jd']
    visit = candidate['pdiffimfilename'].split('_')[1]

    ret = redis_conn.incr(visit + "_alertcount")
    redis_conn.setnx(visit + "_field", field)
    redis_conn.setnx(visit + "_filter", candidate['fid'])
    redis_conn.setnx(visit + "_programid", candidate['programid'])

    # This could be cleaned when they , but easier
    # now to expire them
    if expire:
        redis_conn.expire(visit + "_alertcount", 3600)
        redis_conn.expire(visit + "_field", 3600)

    if date:
        t = datetime.now()
        redis_conn.setnx(visit + "_firstseen", t.isoformat())
        redis_conn.set(visit + "_lastseen", t.isoformat())

    # Do this last, so clients won't see the new visits until all
    # fields are updated
    redis_conn.zadd("visits", int(jd * 24 * 3600), visit)
    return ret

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('topic', type=str,
                        help='Name of Kafka topic to listen to.')
    parser.add_argument("--kafka", type=str, default="localhost:9092",
                        help="Address of Kafka server")
    parser.add_argument('--group', type=str,
                        help='Globally unique name of the consumer group. '
                        'Consumers in the same group will share messages '
                        '(i.e., only one consumer will receive a message, '
                        'as in a queue). Default is value of $HOSTNAME.')

    args = parser.parse_args()

    # Configure consumer connection to Kafka broker
    conf = {'bootstrap.servers': args.kafka,
            'default.topic.config': {'auto.offset.reset': 'earliest'}}
    if args.group:
        conf['group.id'] = args.group
    else:
        conf['group.id'] = "cts_test"

    redis_conn = redis.StrictRedis("127.0.0.1")

    # Configure Avro reader schema
    schema_files = ["../ztf-avro-alert/schema/candidate.avsc",
                    "../ztf-avro-alert/schema/cutout.avsc",
                    "../ztf-avro-alert/schema/prv_candidate.avsc",
                    "../ztf-avro-alert/schema/alert.avsc"]


    # Start consumer and print alert stream
    streamReader = alertConsumer.AlertConsumer(
                        args.topic, schema_files, **conf)

    while True:
        try:
            messages = streamReader.poll(decode=True, timeout=2)

            if messages is None:
                continue

            for msg in messages:
                process_alert(msg, redis_conn, date=True)

        except alertConsumer.EopError as e:
            # Write when reaching end of partition
            sys.stderr.write(e.message)
        except IndexError:
            sys.stderr.write('%% Data cannot be decoded\n')
        except UnicodeDecodeError:
            sys.stderr.write('%% Unexpected data format received\n')
        except KeyboardInterrupt:
            sys.stderr.write('%% Aborted by user\n')
            sys.exit()


if __name__ == "__main__":
    main()
