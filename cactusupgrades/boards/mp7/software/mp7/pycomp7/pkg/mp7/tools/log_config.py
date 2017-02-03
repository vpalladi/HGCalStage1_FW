#
# Copyright (C) 2010-2012 Vinay Sajip. All rights reserved. Licensed under the new BSD license.
#
import logging
import os

#pylint: skip-file

# Experimental stuff / likely to be dangerous
__logging_notice_level = 25

logging.NOTICE=__logging_notice_level
logging.addLevelName(logging.NOTICE, "NOTICE")
def notice(self, message, *args, **kws):
    # Yes, logger takes its '*args' as 'args'.
    self._log(logging.NOTICE, message, args, **kws)
setattr(logging.Logger,'notice',notice)

logging.notice = logging.root.notice


class ColorizingStreamHandler(logging.StreamHandler):
    # color names to indices
    color_map = {
        'black': 0,
        'red': 1,
        'green': 2,
        'yellow': 3,
        'blue': 4,
        'magenta': 5,
        'cyan': 6,
        'white': 7,
    }

    #levels to (background, foreground, bold/intense)

    level_map = {
        logging.DEBUG: (None, 'cyan', False),
        logging.INFO: (None, 'blue', False),
        logging.NOTICE: (None, 'green', False),
        logging.WARNING: (None, 'yellow', False),
        logging.ERROR: (None, 'red', False),
        logging.CRITICAL: ('red', 'white', True),
    }
    csi = '\x1b['
    reset = '\x1b[0m'

    def __init__(self, level_map=None, *args, **kwargs):
        if level_map is not None:
            self.level_map = level_map
        logging.StreamHandler.__init__(self, *args, **kwargs)

    @property
    def is_tty(self):
        isatty = getattr(self.stream, 'isatty', None)
        return isatty and isatty()

    def emit(self, record):
        try:
            message = self.format(record)
            stream = self.stream
            if not self.is_tty:
                stream.write(message)
            else:
                self.output_colorized(message)
            stream.write(getattr(self, 'terminator', '\n'))
            self.flush()
        except (KeyboardInterrupt, SystemExit):
            raise
        except:
            self.handleError(record)

    def output_colorized(self, message):
        self.stream.write(message)

    def colorize(self, message, record):
        if record.levelno in self.level_map:
            bg, fg, bold = self.level_map[record.levelno]
            params = []
            if bg in self.color_map:
                params.append(str(self.color_map[bg] + 40))
            if fg in self.color_map:
                params.append(str(self.color_map[fg] + 30))
            if bold:
                params.append('1')
            if params:
                message = ''.join((self.csi, ';'.join(params),
                                   'm', message, self.reset))
        return message

    def format(self, record):
        message = logging.StreamHandler.format(self, record)
        if self.is_tty:
            # Don't colorize any traceback
            parts = message.split('\n', 1)
            parts[0] = self.colorize(parts[0], record)
            message = '\n'.join(parts)
        return message


def initLogging( level, logpath=None, mode='a' ):

    root = logging.getLogger()
    if any([isinstance(h,ColorizingStreamHandler) for h in root.handlers]):
        root.info('Logging already initialized')
        return
    root.setLevel(logging.DEBUG)

    # define the colored console handler
    console = ColorizingStreamHandler()
    console.setLevel(level)
    # set a format which is simpler for console use
    formatter = logging.Formatter('%(asctime)s py7 %(levelname)-8s | %(message)s')
    # tell the handler to use this format
    console.setFormatter(formatter)
    # add the handler to the root logger
    root.addHandler(console)

    if logpath:
        # define the logfile handler
        logfile = logging.FileHandler( logpath,mode )

        # more verbose format for the logfile
        fileformatter = logging.Formatter('%(asctime)s %(levelname)-8s: %(message)s')
        logfile.setFormatter(fileformatter)
        logfile.setLevel(logging.DEBUG)
        root.addHandler(logfile)

        root.info('>>> Logging to %s',logpath)



def main():
    root = logging.getLogger()
    root.setLevel(logging.DEBUG)
    root.addHandler(ColorizingStreamHandler())
    logging.debug('DEBUG')
    logging.info('INFO')
    root.notice('NOTICE')
    logging.warning('WARNING')
    logging.error('ERROR')
    logging.critical('CRITICAL')

if __name__ == '__main__':
    main()
